class SwipesController < ApplicationController
  BATCH_SIZE = 10
  RECENT_IMPRESSION_LIMIT = 10

  before_action :authenticate_user!

  def index
    @selected_category = Category.find_by(id: params[:category_id])
    @selected_tags = Tag.where(id: Array(params[:tag_ids]).reject(&:blank?)).order(:name)
    reset_progress if reset_progress_requested?
    refill_recipes_if_needed
    @recipes = swipe_recipes
    @recipe = @recipes.first
    @liked_recipes = liked_recipes
    @show_relax_condition_prompt = show_relax_condition_prompt?
    record_impressions(@recipes)
  end

  # スワイプ結果を保存する。
  # HTMLリクエストでは従来の画面遷移、JSONリクエストでは画面内スワイプ用に204だけ返す。
  def create
    recipe = Recipe.find(params[:recipe_id])
    direction = params[:direction].to_s

    unless Swipe.directions.key?(direction)
      return head :unprocessable_entity if request.format.json?

      return redirect_to swipes_path(redirect_params), alert: "スワイプ結果を保存できませんでした。"
    end

    swipe = Swipe.find_or_initialize_by(user: current_user, recipe: recipe)
    swipe.update!(direction: direction)

    return head :no_content if request.format.json?

    redirect_to swipes_path(redirect_params)
  end

  # 画面内スワイプでカードが少なくなった時に、追加候補をJSONで返す。
  def batch
    @selected_category = Category.find_by(id: params[:category_id])
    @selected_tags = Tag.where(id: Array(params[:tag_ids]).reject(&:blank?)).order(:name)
    recipes = filtered_recipes.where.not(id: seen_recipe_ids).limit(BATCH_SIZE).to_a
    record_impressions(recipes)

    render json: {
      recipes: recipes.map { |recipe| recipe_payload(recipe) },
      finished: recipes.empty?
    }
  end

  def select
    recipe = Recipe.find(params[:recipe_id])
    selection = current_user.daily_selections.find_or_initialize_by(selected_on: Date.current)
    selection.recipe = recipe
    selection.save!

    redirect_to recipe_path(recipe), notice: "今日の一品を決定しました。"
  end

  private

  # 条件に合う候補を返す。
  # 直近表示したレシピは除外するが、除外すると候補が尽きる場合は元の候補に戻す。
  def filtered_recipes
    recipes = base_filtered_recipes
    recipes_without_recent_impressions = recipes.where.not(id: recent_impression_recipe_ids)

    return recipes_without_recent_impressions if recipes_without_recent_impressions.exists?

    recipes
  end

  # 詳細画面から戻った場合は、見ていたレシピを先頭カードに戻す。
  def swipe_recipes
    recipes = filtered_recipes.limit(BATCH_SIZE).to_a
    focus_recipe = focused_recipe

    return recipes if focus_recipe.blank?

    [focus_recipe, *recipes.reject { |recipe| recipe.id == focus_recipe.id }].first(BATCH_SIZE)
  end

  def focused_recipe
    return if params[:focus_recipe_id].blank?

    base_filtered_recipes.find_by(id: params[:focus_recipe_id])
  end

  # カテゴリ・タグ・スワイプ済み除外だけを適用した候補。
  # 表示履歴の除外を含めないため、詳細画面から戻るレシピの再取得にも使える。
  def base_filtered_recipes
    recipes = Recipe.includes(:category, :tags, image_attachment: :blob).random_order
    recipes = recipes.where(category: @selected_category) if @selected_category.present?
    recipes = recipes.where(id: RecipeTag.where(tag_id: @selected_tags.select(:id)).select(:recipe_id)) if @selected_tags.any?
    recipes = recipes.where.not(id: current_user.swipes.select(:recipe_id))
    recipes
  end

  def reset_target_recipes
    recipes = Recipe.all
    recipes = recipes.where(category: @selected_category) if @selected_category.present?
    recipes = recipes.where(id: RecipeTag.where(tag_id: @selected_tags.select(:id)).select(:recipe_id)) if @selected_tags.any?
    recipes
  end

  def liked_recipes
    recipes = Recipe.includes(:category, :tags, image_attachment: :blob)
                    .joins(:swipes)
                    .where(swipes: { user: current_user, direction: Swipe.directions[:liked] })
                    .order("swipes.updated_at DESC")
    recipes = recipes.where(category: @selected_category) if @selected_category.present?
    recipes = recipes.where(id: RecipeTag.where(tag_id: @selected_tags.select(:id)).select(:recipe_id)) if @selected_tags.any?
    recipes
  end

  def redirect_params
    {
      category_id: params[:category_id].presence,
      tag_ids: Array(params[:tag_ids]).reject(&:blank?)
    }.compact
  end

  def recent_impression_recipe_ids
    current_user.recipe_impressions.order(displayed_at: :desc).limit(RECENT_IMPRESSION_LIMIT).select(:recipe_id)
  end

  def record_impression(recipe)
    current_user.recipe_impressions.create!(recipe: recipe, displayed_at: Time.current)
  end

  def record_impressions(recipes)
    recipes.each do |recipe|
      record_impression(recipe)
    end
  end

  def reset_progress_requested?
    params[:reset_progress] == "true"
  end

  def reset_progress
    target_recipe_ids = reset_target_recipes.select(:id)
    current_user.swipes.where(recipe_id: target_recipe_ids).delete_all
    current_user.recipe_impressions.where(recipe_id: target_recipe_ids).delete_all
  end

  # DB内の候補が少ない場合に、楽天APIからカテゴリのランキングレシピを補充する。
  # API失敗時もスワイプ画面自体は表示したいので、例外はログに残して握りつぶす。
  def refill_recipes_if_needed
    return unless should_refill_recipes?

    RakutenRecipe::RankingImporter.new.import(@selected_category)
  rescue RakutenRecipe::Client::MissingCredentialsError,
         RakutenRecipe::Client::RequestError,
         RakutenRecipe::RankingImporter::ImportError => e
    Rails.logger.warn("Rakuten recipe refill failed: #{e.class} #{e.message}")
  end

  # 楽天APIにはKIMEAL独自タグがないため、タグ条件ありの場合は補充対象外にしている。
  def should_refill_recipes?
    @selected_category.present? &&
      @selected_category.external_id.present? &&
      @selected_tags.empty? &&
      filtered_recipes.limit(BATCH_SIZE).count < BATCH_SIZE
  end

  # タグ条件で候補が少ない場合に、タグを外して探す提案を出すか判定する。
  def show_relax_condition_prompt?
    @selected_category.present? &&
      @selected_tags.any? &&
      params[:keep_tag_condition] != "true" &&
      filtered_recipes.limit(BATCH_SIZE).count < BATCH_SIZE
  end

  def seen_recipe_ids
    Array(params[:seen_recipe_ids]).reject(&:blank?)
  end

  def recipe_payload(recipe)
    {
      id: recipe.id,
      html: render_to_string(
        partial: "swipes/card",
        formats: [:html],
        locals: { recipe: recipe, hidden: true, return_path: swipes_return_path(recipe) }
      )
    }
  end

  def swipes_return_path(recipe)
    swipes_path(
      category_id: @selected_category&.id,
      tag_ids: @selected_tags.map(&:id),
      focus_recipe_id: recipe.id
    )
  end
end

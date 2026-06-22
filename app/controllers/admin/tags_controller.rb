module Admin
  class TagsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_tag, only: [:update, :destroy]

    def index
      authorize Tag

      @tag = Tag.new
      @tags = Tag.order(:created_at)
      @editing_tag_id = params[:editing_tag_id].to_s
    end

    def create
      authorize Tag

      @tag = Tag.new(tag_params)

      if @tag.save
        redirect_to admin_tags_path, notice: "タグを追加しました。"
      else
        @tags = Tag.order(:created_at)
        @editing_tag_id = nil
        render :index, status: :unprocessable_content
      end
    end

    def update
      authorize @tag

      if @tag.update(tag_params)
        redirect_to admin_tags_path, notice: "タグを更新しました。"
      else
        @editing_tag_id = @tag.id.to_s
        @tags = Tag.order(:created_at).map { |tag| tag.id == @tag.id ? @tag : tag }
        @tag = Tag.new
        render :index, status: :unprocessable_content
      end
    end

    def destroy
      authorize @tag

      @tag.destroy!
      redirect_to admin_tags_path, notice: "タグを削除しました。"
    end

    private

    def set_tag
      @tag = Tag.find(params[:id])
    end

    def tag_params
      params.require(:tag).permit(:name)
    end
  end
end

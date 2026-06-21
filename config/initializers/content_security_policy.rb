# Content Security Policyを設定する場合はここで有効化する
#
# Rails.application.configure do
#   config.content_security_policy do |policy|
#     policy.default_src :self, :https
#     policy.font_src    :self, :https, :data
#     policy.img_src     :self, :https, :data
#     policy.object_src  :none
#     policy.script_src  :self, :https
#     policy.style_src   :self, :https
#   end
#
#   # importmapやinline script/styleを許可するnonceを生成する
#   config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
#   config.content_security_policy_nonce_directives = %w[script-src style-src]
#
#   # 違反をブロックせずレポートだけ受けたい場合に有効化する
#   # config.content_security_policy_report_only = true
# end

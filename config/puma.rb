# Pumaのスレッド数を設定する。
# DB接続数もこの値に合わせて確保する必要がある。
threads_count = ENV.fetch("RAILS_MAX_THREADS", 3)
threads threads_count, threads_count

# Pumaが待ち受けるポート
port ENV.fetch("PORT", 3000)

# bin/rails restart でPumaを再起動できるようにする
plugin :tmp_restart

# 単一サーバー運用時にSolid QueueをPuma内で動かす
plugin :solid_queue if ENV["SOLID_QUEUE_IN_PUMA"]

# PIDファイルを明示した場合のみ設定する
pidfile ENV["PIDFILE"] if ENV["PIDFILE"]

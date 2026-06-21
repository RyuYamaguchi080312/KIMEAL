class ApplicationJob < ActiveJob::Base
  # デッドロックしたジョブを自動リトライする場合に有効化する
  # retry_on ActiveRecord::Deadlocked

  # 対象レコードが削除済みの場合にジョブを破棄する
  # discard_on ActiveJob::DeserializationError
end

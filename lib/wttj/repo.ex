defmodule Wttj.Repo do
  use Ecto.Repo,
    otp_app: :wttj,
    adapter: Ecto.Adapters.Postgres,
    types: Core.PostgresTypes
end

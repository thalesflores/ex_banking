defmodule ExBanking.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: true

    children = [
      supervisor(ExBanking.Supervisor, [])
    ]

    opts = [strategy: :one_for_one, name: ExBanking.Application]
    Supervisor.start_link(children, opts)
  end
end

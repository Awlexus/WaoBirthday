import Config

config :mnesia,
  dir: '.mnesia/#{Mix.env()}/#{node()}'

config :wao_birthday, token: System.get_env("TOKEN")

config :wao_birthday, WaoBirthday.Scheduler,
  debug_logging: false,
  jobs: [
    {"@daily", {WaoBirthday.Scheduler, :queue_reminders, []}}
  ]


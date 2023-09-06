# Configuration for the testing environment
import Config

config :serum_md, service: Serum.DevServer.Service.Mock
config :serum_md, command_handler: Serum.DevServer.CommandHandler.Mock

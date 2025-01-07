defmodule ShatWeb.ChatHTML do
  @moduledoc """
  This module contains pages rendered by ChatController.

  See the `chat_html` directory for all templates available.
  """
  use ShatWeb, :html

  embed_templates "chat_html/*"
end

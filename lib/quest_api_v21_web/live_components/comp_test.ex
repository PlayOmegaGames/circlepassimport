defmodule QuestApiV21Web.CompTest do
  use Phoenix.LiveComponent


  on_mount {QuestApiV21Web.AccountAuth, :mount_current_account}

  def render(assigns) do


    ~H"""

      <div class="mt-40">
      </div>
    """
  end
end

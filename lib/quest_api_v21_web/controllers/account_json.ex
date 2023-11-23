defmodule QuestApiV21Web.AccountJSON do
  alias QuestApiV21.Quests.Quest
  alias QuestApiV21.Accounts.Account
  alias QuestApiV21.Badges.Badge
  alias QuestApiV21.Quests.Quest

  @doc """
  Renders a list of accounts.
  """
  def index(%{accounts: accounts}) do
    %{data: for(account <- accounts, do: data(account))}
  end

  @doc """
  Renders a single account.
  """
  def show(%{account: account}) do
    %{data: data(account)}
  end

  @doc """
  Renders an error response.
  """
  def render("error.json", %{message: message}) do
    %{errors: %{detail: message}}
  end

  def render("account.json", %{account: account, jwt: jwt}) do
    %{
      jwt: jwt,
      data: data(account)
    }
  end
  
  def data(%Account{badges: badges, quests: quests} = account) do
    %{
      id: account.id,
      name: account.name,
      email: account.email,
      badges: badges_data(badges),
      quests: quests_data(quests)
    }
  end

  defp badges_data(badges) do
    Enum.map(badges, fn %Badge{id: id, name: name} ->
      %{
        id: id,
        name: name
      }
    end)
  end

  defp quests_data(quests) do
    Enum.map(quests, fn %Quest{id: id, name: name} ->
      %{
        id: id,
        name: name
      }
    end)
  end
end

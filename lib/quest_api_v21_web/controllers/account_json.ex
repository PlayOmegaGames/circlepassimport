defmodule QuestApiV21Web.AccountJSON do
  alias QuestApiV21.Accounts.Account
  alias QuestApiV21.Badges.Badge

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

  def data(%Account{badges: badges} = account) do
    %{
      id: account.id,
      name: account.name,
      email: account.email,
      badges: badges_data(badges)
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
end

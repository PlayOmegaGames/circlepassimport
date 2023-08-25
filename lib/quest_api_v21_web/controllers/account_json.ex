defmodule QuestApiV21Web.AccountJSON do
  alias QuestApiV21.Accounts.Account

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

  defp data(%Account{} = account) do
    %{
      id: account.id,
      name: account.name,
      email: account.email,
      hashed_passowrd: account.hashed_passowrd
    }
  end
end

defmodule QuestApiV21Web.AccountJSON do
  alias QuestApiV21.Accounts.Account
  alias QuestApiV21.Collection_Points.Collection_Point

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

  defp data(%Account{collection_points: collection_points} = account) do
    %{
      id: account.id,
      name: account.name,
      email: account.email,
      hashed_passowrd: account.hashed_passowrd,
      collection_points: collection_points_data(collection_points)
    }
  end

  defp collection_points_data(collection_points) do
    Enum.map(collection_points, fn %Collection_Point{id: id, name: name} ->
      %{
        id: id,
        name: name
      }
    end)
  end
end

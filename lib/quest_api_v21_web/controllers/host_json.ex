defmodule QuestApiV21Web.HostJSON do
  alias QuestApiV21.Hosts.Host
  alias QuestApiV21.Organizations.Organization

  @doc """
  Renders a list of hosts.
  """
  def index(%{hosts: hosts}) do
    %{data: for(host <- hosts, do: data(host))}
  end

  @doc """
  Renders a single host.
  """
  def show(%{host: host}) do
    %{data: data(host)}
  end

  @doc """
  Renders an error response.
  """
  def render("error.json", %{message: message}) do
    %{errors: %{detail: message}}
  end

  defp data(%Host{organizations: organizations} = host) do
    %{
      id: host.id,
      name: host.name,
      email: host.email,
      hashed_password: host.hashed_password,
      organizations: organizations_data(organizations)
    }
  end

  defp organizations_data(organizations) do
    Enum.map(organizations, fn %Organization{id: id, name: name} ->
      %{
        id: id,
        name: name
      }
    end)
  end
end

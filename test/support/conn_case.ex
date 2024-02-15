defmodule QuestApiV21Web.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use QuestApiV21Web.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # The default endpoint for testing
      @endpoint QuestApiV21Web.Endpoint

      use QuestApiV21Web, :verified_routes

      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import QuestApiV21Web.ConnCase
    end
  end

  setup tags do
    QuestApiV21.DataCase.setup_sandbox(tags)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  @doc """
  Setup helper that registers and logs in superadmin.

      setup :register_and_log_in_superadmin

  It stores an updated connection and a registered superadmin in the
  test context.
  """
  def register_and_log_in_superadmin(%{conn: conn}) do
    superadmin = QuestApiV21.AdminFixtures.superadmin_fixture()
    %{conn: log_in_superadmin(conn, superadmin), superadmin: superadmin}
  end

  @doc """
  Logs the given `superadmin` into the `conn`.

  It returns an updated `conn`.
  """
  def log_in_superadmin(conn, superadmin) do
    token = QuestApiV21.Admin.generate_superadmin_session_token(superadmin)

    conn
    |> Phoenix.ConnTest.init_test_session(%{})
    |> Plug.Conn.put_session(:superadmin_token, token)
  end
end

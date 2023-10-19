defmodule QuestApiV21Web.AuthController do
  use QuestApiV21Web, :controller  # Inherits from the Phoenix controller module

  alias QuestApiV21.{Guardian, Repo, Accounts.Account}  # Shortens module names for easier reference
  alias QuestApiV21.Accounts

  # `sign_in` function to handle user authentication
  def sign_in(conn, %{"user" => %{"email" => email, "password" => password}}) do

    # Attempts to find a user in the database with the provided email
    case Repo.get_by(Account, email: email) do

      # If no user is found, returns a 404 Not Found status and a JSON error message
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "User not found"})

      # If a user is found, verifies the provided password against the stored hashed password
      user ->
        if Bcrypt.verify_pass(password, user.hashed_password) do

          # If the password is correct, generates a JWT, puts it in the response header,
          # and returns it in the response body
          {:ok, jwt, _full_claims} = Guardian.encode_and_sign(user)
          conn
          |> put_resp_header("authorization", "Bearer #{jwt}")
          |> json(%{jwt: jwt})
        else

          # If the password is incorrect, returns a 401 Unauthorized status and a JSON error message
          conn
          |> put_status(:unauthorized)
          |> json(%{error: "Incorrect password"})
        end
    end
  end

  # `sign_up` function to handle account creation
  def sign_up(conn, %{"account" => account_params}) do
    with {:ok, %Account{} = account} <- Accounts.create_account(account_params) do
      {:ok, jwt, _full_claims} = Guardian.encode_and_sign(account)
      conn
      |> put_status(:created)
      |> put_resp_header("authorization", "Bearer #{jwt}")
      |> json(%{jwt: jwt})
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(QuestApiV21Web.ChangesetView)
        |> render("error.json", changeset: changeset)
    end
  end
end

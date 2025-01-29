defmodule Signbank.Accounts.UserNotifier do
  @moduledoc false

  use SignbankWeb, :html
  import Swoosh.Email

  alias Signbank.Mailer

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, body) do
    html = heex_to_html(body)
    text = html_to_text(html)

    email =
      new()
      |> to(recipient)
      |> from(
        {Application.fetch_env!(:signbank, :application_name),
         Application.fetch_env!(:signbank, Signbank.Mailer)[:from_address]}
      )
      |> subject(subject)
      |> html_body(html)
      |> text_body(text)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(user, url) do
    assigns = %{
      user: user,
      url: url,
      application_name: Application.fetch_env!(:signbank, :application_name)
    }

    deliver(
      user.email,
      "Confirmation instructions",
      ~H"""
      <.email_layout>
        <h1>{@application_name} registration.</h1>
        <p>Hi {@user.email},</p>
        <p>You can confirm your {@application_name} account by visiting the URL below:</p>
        <p>
          {@url}
        </p>
        <p>If you didn't create an account with us, please ignore this email.</p>
        <p>Best,</p>
        <p>The {@application_name} Team</p>
      </.email_layout>
      """
    )
  end

  @doc """
  Deliver instructions to reset a user password.
  """
  def deliver_reset_password_instructions(user, url) do
    assigns = %{
      user: user,
      url: url,
      application_name: Application.fetch_env!(:signbank, :application_name)
    }

    deliver(
      user.email,
      "Reset password instructions",
      ~H"""
      <.email_layout>
        <h1>Reset password instructions</h1>
        <p>Hi {@user.email},</p>
        <p>You can reset your password by visiting the URL below:</p>
        <p>
          {@url}
        </p>
        <p>If you didn't request this change, please ignore this.</p>
        <p>Best,</p>
        <p>The {@application_name} Team</p>
      </.email_layout>
      """
    )
  end

  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(user, url) do
    assigns = %{
      user: user,
      url: url,
      application_name: Application.fetch_env!(:signbank, :application_name)
    }

    deliver(
      user.email,
      "Update email instructions",
      ~H"""
      <.email_layout>
        <%!-- TODO: move application name to environment variables --%>
        <h1>Update email instructions</h1>
        <p>Hi {@user.email},</p>
        <p>You can change your email by visiting the URL below:</p>
        <p>
          {@url}
        </p>
        <p>If you didn't request this change, please ignore this.</p>
        <p>Best,</p>
        <p>The {@application_name} Team</p>
      </.email_layout>
      """
    )
  end

  defp heex_to_html(template) do
    template
    |> Phoenix.HTML.Safe.to_iodata()
    |> IO.iodata_to_binary()
  end

  defp html_to_text(html) do
    html
    |> Floki.parse_document!()
    |> Floki.find("body")
    |> Floki.text(sep: "\n\n")
  end

  defp email_layout(assigns) do
    ~H"""
    <!DOCTYPE html>
    <html lang="en">
      <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <style>
          body {
            font-family: system-ui, sans-serif;
            margin: 3em auto;
            overflow-wrap: break-word;
            word-break: break-all;
            max-width: 1024px;
            padding: 0 1em;
          }
        </style>
      </head>
      <body>
        {render_slot(@inner_block)}
      </body>
    </html>
    """
  end
end

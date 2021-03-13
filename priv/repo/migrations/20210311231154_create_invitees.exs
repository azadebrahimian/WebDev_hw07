defmodule EventApp.Repo.Migrations.CreateInvitees do
  use Ecto.Migration

  def change do
    create table(:invitees) do
      add :response, :string, default: "Haven't responded", null: false
      add :user_id, references(:users), null: false
      add :event_id, references(:events), null: false

      timestamps()
    end

  end
end

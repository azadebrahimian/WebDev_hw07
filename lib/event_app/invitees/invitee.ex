defmodule EventApp.Invitees.Invitee do
  use Ecto.Schema
  import Ecto.Changeset

  schema "invitees" do
    field :response, :string
    field :user_id, :id

    belongs_to :event, EventApp.Events.Event
    timestamps()
  end

  @doc false
  def changeset(invitee, attrs) do
    invitee
    |> cast(attrs, [:response, :user_id, :event_id])
    |> validate_required([:response, :user_id, :event_id])
  end
end

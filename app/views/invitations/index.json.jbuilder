json.array!(@invitations) do |invitation|
  json.extract! invitation, :id, :event_id, :user_id
  json.url invitation_url(invitation, format: :json)
end

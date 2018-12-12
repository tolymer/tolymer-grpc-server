# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: proto/tolymer.proto

require 'google/protobuf'

require 'google/protobuf/empty_pb'
require 'google/protobuf/field_mask_pb'
Google::Protobuf::DescriptorPool.generated_pool.build do
  add_message "tolymer.v1.GetEventRequest" do
    optional :event_token, :string, 1
  end
  add_message "tolymer.v1.CreateEventRequest" do
    optional :description, :string, 1
    repeated :participants, :string, 2
  end
  add_message "tolymer.v1.UpdateEventRequest" do
    optional :event_token, :string, 1
    optional :description, :string, 2
    optional :update_mask, :message, 3, "google.protobuf.FieldMask"
  end
  add_message "tolymer.v1.UpdateParticipantsRequest" do
    optional :event_token, :string, 1
    repeated :renaming_participants, :message, 2, "tolymer.v1.Participant"
    repeated :adding_names, :string, 3
    repeated :deleting_ids, :int64, 4
  end
  add_message "tolymer.v1.CreateParticipantRequest" do
    optional :event_token, :string, 1
    optional :name, :string, 2
  end
  add_message "tolymer.v1.UpdateParticipantRequest" do
    optional :event_token, :string, 1
    optional :participant_id, :int64, 2
    optional :name, :string, 3
    optional :update_mask, :message, 4, "google.protobuf.FieldMask"
  end
  add_message "tolymer.v1.DeleteParticipantRequest" do
    optional :event_token, :string, 1
    optional :participant_id, :int64, 2
  end
  add_message "tolymer.v1.CreateGameRequest" do
    optional :event_token, :string, 1
    repeated :results, :message, 2, "tolymer.v1.GameResult"
  end
  add_message "tolymer.v1.UpdateGameRequest" do
    optional :event_token, :string, 1
    optional :game_id, :int64, 2
    repeated :results, :message, 3, "tolymer.v1.GameResult"
    optional :update_mask, :message, 4, "google.protobuf.FieldMask"
  end
  add_message "tolymer.v1.DeleteGameRequest" do
    optional :event_token, :string, 1
    optional :game_id, :int64, 2
  end
  add_message "tolymer.v1.PostTipRequest" do
    optional :event_token, :string, 1
    repeated :results, :message, 2, "tolymer.v1.TipResult"
  end
  add_message "tolymer.v1.DeleteTipRequest" do
    optional :event_token, :string, 1
  end
  add_message "tolymer.v1.Event" do
    optional :token, :string, 1
    optional :description, :string, 2
    repeated :participants, :message, 3, "tolymer.v1.Participant"
    repeated :games, :message, 4, "tolymer.v1.Game"
    optional :tip, :message, 5, "tolymer.v1.Tip"
  end
  add_message "tolymer.v1.Participant" do
    optional :id, :int64, 1
    optional :name, :string, 2
  end
  add_message "tolymer.v1.Game" do
    optional :id, :int64, 1
    optional :event_token, :string, 2
    optional :rank, :int32, 3
    repeated :results, :message, 4, "tolymer.v1.GameResult"
  end
  add_message "tolymer.v1.GameResult" do
    optional :participant_id, :int64, 1
    optional :rank, :int32, 2
    optional :score, :double, 3
  end
  add_message "tolymer.v1.Tip" do
    repeated :results, :message, 1, "tolymer.v1.TipResult"
  end
  add_message "tolymer.v1.TipResult" do
    optional :participant_id, :int64, 1
    optional :score, :double, 2
  end
end

module Tolymer
  module V1
    GetEventRequest = Google::Protobuf::DescriptorPool.generated_pool.lookup("tolymer.v1.GetEventRequest").msgclass
    CreateEventRequest = Google::Protobuf::DescriptorPool.generated_pool.lookup("tolymer.v1.CreateEventRequest").msgclass
    UpdateEventRequest = Google::Protobuf::DescriptorPool.generated_pool.lookup("tolymer.v1.UpdateEventRequest").msgclass
    UpdateParticipantsRequest = Google::Protobuf::DescriptorPool.generated_pool.lookup("tolymer.v1.UpdateParticipantsRequest").msgclass
    CreateParticipantRequest = Google::Protobuf::DescriptorPool.generated_pool.lookup("tolymer.v1.CreateParticipantRequest").msgclass
    UpdateParticipantRequest = Google::Protobuf::DescriptorPool.generated_pool.lookup("tolymer.v1.UpdateParticipantRequest").msgclass
    DeleteParticipantRequest = Google::Protobuf::DescriptorPool.generated_pool.lookup("tolymer.v1.DeleteParticipantRequest").msgclass
    CreateGameRequest = Google::Protobuf::DescriptorPool.generated_pool.lookup("tolymer.v1.CreateGameRequest").msgclass
    UpdateGameRequest = Google::Protobuf::DescriptorPool.generated_pool.lookup("tolymer.v1.UpdateGameRequest").msgclass
    DeleteGameRequest = Google::Protobuf::DescriptorPool.generated_pool.lookup("tolymer.v1.DeleteGameRequest").msgclass
    PostTipRequest = Google::Protobuf::DescriptorPool.generated_pool.lookup("tolymer.v1.PostTipRequest").msgclass
    DeleteTipRequest = Google::Protobuf::DescriptorPool.generated_pool.lookup("tolymer.v1.DeleteTipRequest").msgclass
    Event = Google::Protobuf::DescriptorPool.generated_pool.lookup("tolymer.v1.Event").msgclass
    Participant = Google::Protobuf::DescriptorPool.generated_pool.lookup("tolymer.v1.Participant").msgclass
    Game = Google::Protobuf::DescriptorPool.generated_pool.lookup("tolymer.v1.Game").msgclass
    GameResult = Google::Protobuf::DescriptorPool.generated_pool.lookup("tolymer.v1.GameResult").msgclass
    Tip = Google::Protobuf::DescriptorPool.generated_pool.lookup("tolymer.v1.Tip").msgclass
    TipResult = Google::Protobuf::DescriptorPool.generated_pool.lookup("tolymer.v1.TipResult").msgclass
  end
end

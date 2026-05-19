using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.Communication.DTOs;
using ConfidantPostgreSQL.Modules.Communication.Models;
using Npgsql;

namespace ConfidantPostgreSQL.Modules.Communication.Repository
{
    public class CommunicationRepository : ICommunicationRepository
    {
        private readonly string _connectionString;

        public CommunicationRepository(string connectionString)
        {
            _connectionString = connectionString;
        }

        public async Task<IEnumerable<Notification>> GetNotificationsAllAsync()
        {
            var list = new List<Notification>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_notifications_select_all01();";

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(new Notification
                {
                    IdNotification = reader.GetGuid(reader.GetOrdinal("id_notification")),
                    IdUser = reader.GetGuid(reader.GetOrdinal("id_user")),
                    Type = GetNullableString(reader, "type"),
                    Message = GetNullableString(reader, "message"),
                    WasRead = GetBoolDefaultFalse(reader, "was_read"),
                    CreatedAt = GetNullableDateTime(reader, "created_at"),
                    UpdatedAt = GetNullableDateTime(reader, "updated_at")
                });
            }

            return list;
        }

        public async Task<Notification?> GetNotificationByIdAsync(Guid idNotification)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_notifications_select_details01(@id_notification);";
            cmd.Parameters.AddWithValue("id_notification", idNotification);

            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;

            return new Notification
            {
                IdNotification = reader.GetGuid(reader.GetOrdinal("id_notification")),
                IdUser = reader.GetGuid(reader.GetOrdinal("id_user")),
                Type = GetNullableString(reader, "type"),
                Message = GetNullableString(reader, "message"),
                WasRead = GetBoolDefaultFalse(reader, "was_read"),
                CreatedAt = GetNullableDateTime(reader, "created_at"),
                UpdatedAt = GetNullableDateTime(reader, "updated_at")
            };
        }

        public async Task<Guid> InsertNotificationAsync(Notification notification)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = @"
                INSERT INTO public.notifications (
                    id_user,
                    type,
                    message,
                    was_read,
                    created_at,
                    updated_at
                )
                VALUES (
                    @id_user,
                    @type,
                    @message,
                    COALESCE(@was_read, false),
                    COALESCE(@created_at, now()),
                    COALESCE(@updated_at, now())
                )
                RETURNING id_notification;";

            cmd.Parameters.AddWithValue("id_user", notification.IdUser);
            cmd.Parameters.AddWithValue("type", (object?)notification.Type ?? DBNull.Value);
            cmd.Parameters.AddWithValue("message", (object?)notification.Message ?? DBNull.Value);
            cmd.Parameters.AddWithValue("was_read", (object?)notification.WasRead ?? DBNull.Value);
            cmd.Parameters.AddWithValue("created_at", (object?)notification.CreatedAt ?? DBNull.Value);
            cmd.Parameters.AddWithValue("updated_at", (object?)notification.UpdatedAt ?? DBNull.Value);

            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? Guid.Empty : (Guid)res;
        }

        public async Task<int> UpdateNotificationAsync(Notification notification)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_notifications_update(@id_notification, @id_user, @type, @message, @was_read);";

            cmd.Parameters.AddWithValue("id_notification", notification.IdNotification);
            cmd.Parameters.AddWithValue("id_user", notification.IdUser);
            cmd.Parameters.AddWithValue("type", (object?)notification.Type ?? DBNull.Value);
            cmd.Parameters.AddWithValue("message", (object?)notification.Message ?? DBNull.Value);
            cmd.Parameters.AddWithValue("was_read", notification.WasRead);

            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<int> DeleteNotificationAsync(Guid idNotification)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_notifications_delete(@id_notification);";
            cmd.Parameters.AddWithValue("id_notification", idNotification);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<IEnumerable<Message>> GetMessagesAllAsync()
        {
            var list = new List<Message>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_messages_select_all01();";

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(new Message
                {
                    IdMessage = reader.GetGuid(reader.GetOrdinal("id_message")),
                    SenderUserId = reader.GetGuid(reader.GetOrdinal("sender_user_id")),
                    ReceiverUserId = reader.GetGuid(reader.GetOrdinal("receiver_user_id")),
                    MessageContent = GetNullableString(reader, "message_content"),
                    IsRead = GetBoolDefaultFalse(reader, "is_read"),
                    SentAt = GetNullableDateTime(reader, "sent_at"),
                    ReadAt = GetNullableDateTime(reader, "read_at"),
                    GroupRoomId = GetNullableGuid(reader, "group_room_id")
                });
            }

            return list;
        }

        public async Task<Message?> GetMessageByIdAsync(Guid idMessage)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_messages_select_details01(@id_message);";
            cmd.Parameters.AddWithValue("id_message", idMessage);

            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;

            return new Message
            {
                IdMessage = reader.GetGuid(reader.GetOrdinal("id_message")),
                SenderUserId = reader.GetGuid(reader.GetOrdinal("sender_user_id")),
                ReceiverUserId = reader.GetGuid(reader.GetOrdinal("receiver_user_id")),
                MessageContent = GetNullableString(reader, "message_content"),
                IsRead = GetBoolDefaultFalse(reader, "is_read"),
                SentAt = GetNullableDateTime(reader, "sent_at"),
                ReadAt = GetNullableDateTime(reader, "read_at"),
                GroupRoomId = GetNullableGuid(reader, "group_room_id")
            };
        }

        public async Task<Guid> InsertMessageAsync(Message message)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
                        cmd.CommandText = "SELECT public.usp_messages_insert(@sender_user_id, @receiver_user_id, @message_content, @is_read, @sent_at, @read_at, @group_room_id);";

            cmd.Parameters.AddWithValue("sender_user_id", message.SenderUserId);
            cmd.Parameters.AddWithValue("receiver_user_id", message.ReceiverUserId);
            cmd.Parameters.AddWithValue("message_content", (object?)message.MessageContent ?? DBNull.Value);
            cmd.Parameters.AddWithValue("is_read", message.IsRead);
            cmd.Parameters.AddWithValue("sent_at", (object?)message.SentAt ?? DBNull.Value);
            cmd.Parameters.AddWithValue("read_at", (object?)message.ReadAt ?? DBNull.Value);
            cmd.Parameters.AddWithValue("group_room_id", (object?)message.GroupRoomId ?? DBNull.Value);

            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? Guid.Empty : (Guid)res;
        }

        public async Task<int> UpdateMessageAsync(Message message)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_messages_update(@id_message, @sender_user_id, @receiver_user_id, @message_content, @is_read, @sent_at, @read_at, @group_room_id);";

            cmd.Parameters.AddWithValue("id_message", message.IdMessage);
            cmd.Parameters.AddWithValue("sender_user_id", message.SenderUserId);
            cmd.Parameters.AddWithValue("receiver_user_id", message.ReceiverUserId);
            cmd.Parameters.AddWithValue("message_content", (object?)message.MessageContent ?? DBNull.Value);
            cmd.Parameters.AddWithValue("is_read", message.IsRead);
            cmd.Parameters.AddWithValue("sent_at", (object?)message.SentAt ?? DBNull.Value);
            cmd.Parameters.AddWithValue("read_at", (object?)message.ReadAt ?? DBNull.Value);
            cmd.Parameters.AddWithValue("group_room_id", (object?)message.GroupRoomId ?? DBNull.Value);

            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<int> DeleteMessageAsync(Guid idMessage)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_messages_delete(@id_message);";
            cmd.Parameters.AddWithValue("id_message", idMessage);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<IEnumerable<Contact>> GetContactsAllAsync()
        {
            var list = new List<Contact>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_contacts_select_all01();";

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(new Contact
                {
                    Id = reader.GetGuid(reader.GetOrdinal("id")),
                    OwnerUserId = reader.GetGuid(reader.GetOrdinal("owner_user_id")),
                    ContactUserId = reader.GetGuid(reader.GetOrdinal("contact_user_id")),
                    DisplayNameOverride = GetNullableString(reader, "display_name_override"),
                    Status = reader.GetString(reader.GetOrdinal("status")),
                    Notes = GetNullableString(reader, "notes"),
                    Metadata = GetNullableString(reader, "metadata"),
                    CreatedAt = reader.GetFieldValue<DateTimeOffset>(reader.GetOrdinal("created_at")),
                    UpdatedAt = reader.GetFieldValue<DateTimeOffset>(reader.GetOrdinal("updated_at"))
                });
            }

            return list;
        }

        public async Task<IEnumerable<Contact>> GetContactsByOwnerAsync(Guid ownerUserId)
        {
            var list = new List<Contact>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_contacts_select_by_owner01(@owner_user_id);";
            cmd.Parameters.AddWithValue("owner_user_id", ownerUserId);

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(new Contact
                {
                    Id = reader.GetGuid(reader.GetOrdinal("id")),
                    OwnerUserId = reader.GetGuid(reader.GetOrdinal("owner_user_id")),
                    ContactUserId = reader.GetGuid(reader.GetOrdinal("contact_user_id")),
                    DisplayNameOverride = GetNullableString(reader, "display_name_override"),
                    Status = reader.GetString(reader.GetOrdinal("status")),
                    Notes = GetNullableString(reader, "notes"),
                    Metadata = GetNullableString(reader, "metadata"),
                    CreatedAt = reader.GetFieldValue<DateTimeOffset>(reader.GetOrdinal("created_at")),
                    UpdatedAt = reader.GetFieldValue<DateTimeOffset>(reader.GetOrdinal("updated_at"))
                });
            }

            return list;
        }

        public async Task<Contact?> GetContactByOwnerAndContactAsync(Guid ownerUserId, Guid contactUserId)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
                        cmd.CommandText = @"
                                SELECT *
                                FROM public.contacts
                                WHERE owner_user_id = @owner_user_id
                                    AND contact_user_id = @contact_user_id
                                ORDER BY created_at DESC
                                LIMIT 1;";
            cmd.Parameters.AddWithValue("owner_user_id", ownerUserId);
            cmd.Parameters.AddWithValue("contact_user_id", contactUserId);

            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;

            return new Contact
            {
                Id = reader.GetGuid(reader.GetOrdinal("id")),
                OwnerUserId = reader.GetGuid(reader.GetOrdinal("owner_user_id")),
                ContactUserId = reader.GetGuid(reader.GetOrdinal("contact_user_id")),
                DisplayNameOverride = GetNullableString(reader, "display_name_override"),
                Status = reader.GetString(reader.GetOrdinal("status")),
                Notes = GetNullableString(reader, "notes"),
                Metadata = GetNullableString(reader, "metadata"),
                CreatedAt = reader.GetFieldValue<DateTimeOffset>(reader.GetOrdinal("created_at")),
                UpdatedAt = reader.GetFieldValue<DateTimeOffset>(reader.GetOrdinal("updated_at"))
            };
        }

        public async Task<Contact?> GetContactByIdAsync(Guid id)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_contacts_select_details01(@id);";
            cmd.Parameters.AddWithValue("id", id);

            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;

            return new Contact
            {
                Id = reader.GetGuid(reader.GetOrdinal("id")),
                OwnerUserId = reader.GetGuid(reader.GetOrdinal("owner_user_id")),
                ContactUserId = reader.GetGuid(reader.GetOrdinal("contact_user_id")),
                DisplayNameOverride = GetNullableString(reader, "display_name_override"),
                Status = reader.GetString(reader.GetOrdinal("status")),
                Notes = GetNullableString(reader, "notes"),
                Metadata = GetNullableString(reader, "metadata"),
                CreatedAt = reader.GetFieldValue<DateTimeOffset>(reader.GetOrdinal("created_at")),
                UpdatedAt = reader.GetFieldValue<DateTimeOffset>(reader.GetOrdinal("updated_at"))
            };
        }

        public async Task<Guid> InsertContactAsync(Contact contact)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
                        cmd.CommandText = "SELECT public.usp_contacts_insert(@owner_user_id, @contact_user_id, @display_name_override, @status, @notes, @metadata::jsonb, @created_at, @updated_at);";

            cmd.Parameters.AddWithValue("owner_user_id", contact.OwnerUserId);
            cmd.Parameters.AddWithValue("contact_user_id", contact.ContactUserId);
            cmd.Parameters.AddWithValue("display_name_override", (object?)contact.DisplayNameOverride ?? DBNull.Value);
            cmd.Parameters.AddWithValue("status", (object?)contact.Status ?? DBNull.Value);
            cmd.Parameters.AddWithValue("notes", (object?)contact.Notes ?? DBNull.Value);
            cmd.Parameters.AddWithValue("metadata", (object?)contact.Metadata ?? DBNull.Value);
            cmd.Parameters.AddWithValue("created_at", (object?)contact.CreatedAt == default ? DBNull.Value : contact.CreatedAt);
            cmd.Parameters.AddWithValue("updated_at", (object?)contact.UpdatedAt == default ? DBNull.Value : contact.UpdatedAt);

            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? Guid.Empty : (Guid)res;
        }

        public async Task<Guid> UpsertContactAsync(Contact contact)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
            cmd.CommandText = @"
                INSERT INTO public.contacts (
                    owner_user_id,
                    contact_user_id,
                    display_name_override,
                    status,
                    notes,
                    metadata,
                    created_at,
                    updated_at
                )
                VALUES (
                    @owner_user_id,
                    @contact_user_id,
                    @display_name_override,
                    COALESCE(@status, 'pending'),
                    @notes,
                    @metadata::jsonb,
                    now(),
                    now()
                )
                ON CONFLICT (owner_user_id, contact_user_id)
                DO UPDATE SET
                    display_name_override = COALESCE(EXCLUDED.display_name_override, public.contacts.display_name_override),
                    status = COALESCE(EXCLUDED.status, public.contacts.status),
                    notes = COALESCE(EXCLUDED.notes, public.contacts.notes),
                    metadata = COALESCE(EXCLUDED.metadata, public.contacts.metadata),
                    updated_at = now()
                RETURNING id;";
            cmd.Parameters.AddWithValue("owner_user_id", contact.OwnerUserId);
            cmd.Parameters.AddWithValue("contact_user_id", contact.ContactUserId);
            cmd.Parameters.AddWithValue("display_name_override", (object?)contact.DisplayNameOverride ?? DBNull.Value);
            cmd.Parameters.AddWithValue("status", (object?)contact.Status ?? DBNull.Value);
            cmd.Parameters.AddWithValue("notes", (object?)contact.Notes ?? DBNull.Value);
            cmd.Parameters.AddWithValue("metadata", (object?)contact.Metadata ?? DBNull.Value);

            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? Guid.Empty : (Guid)res;
        }

        public async Task<IEnumerable<ContactUserSummary>> GetContactUserSummariesByOwnerAsync(Guid ownerUserId)
        {
            var list = new List<ContactUserSummary>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
            cmd.CommandText = @"
                SELECT
                    c.id AS contact_id,
                    c.contact_user_id,
                    c.status,
                    u.username,
                    u.display_name,
                    COALESCE(
                        NULLIF(m.message_content, ''),
                        CASE
                            WHEN COALESCE(m.metadata, '') LIKE '%""type"":""file""%' THEN 'Ficheiro enviado'
                            ELSE NULL
                        END
                    ) AS last_message,
                    m.sent_at AS last_message_at
                FROM public.contacts c
                JOIN public.users u ON u.id_user = c.contact_user_id
                LEFT JOIN LATERAL (
                    SELECT
                        msg.message_content,
                        msg.metadata,
                        msg.sent_at
                    FROM public.messages msg
                    WHERE msg.group_room_id IS NULL
                      AND (
                        (msg.sender_user_id = c.owner_user_id AND msg.receiver_user_id = c.contact_user_id)
                        OR
                        (msg.sender_user_id = c.contact_user_id AND msg.receiver_user_id = c.owner_user_id)
                      )
                    ORDER BY msg.sent_at DESC
                    LIMIT 1
                ) m ON TRUE
                WHERE c.owner_user_id = @p_owner_user_id
                ORDER BY COALESCE(m.sent_at, c.created_at) DESC, c.created_at DESC;";
            cmd.Parameters.AddWithValue("p_owner_user_id", ownerUserId);

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(new ContactUserSummary
                {
                    ContactId = reader.GetGuid(reader.GetOrdinal("contact_id")),
                    ContactUserId = reader.GetGuid(reader.GetOrdinal("contact_user_id")),
                    Status = reader.GetString(reader.GetOrdinal("status")),
                    Username = GetNullableString(reader, "username"),
                    DisplayName = GetNullableString(reader, "display_name"),
                    LastMessage = GetNullableString(reader, "last_message"),
                    LastMessageAt = GetNullableDateTime(reader, "last_message_at")
                });
            }

            return list;
        }

        public async Task<int> UpdateContactAsync(Contact contact)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_contacts_update(@id, @owner_user_id, @contact_user_id, @display_name_override, @status, @notes, @metadata::jsonb);";

            cmd.Parameters.AddWithValue("id", contact.Id);
            cmd.Parameters.AddWithValue("owner_user_id", contact.OwnerUserId);
            cmd.Parameters.AddWithValue("contact_user_id", contact.ContactUserId);
            cmd.Parameters.AddWithValue("display_name_override", (object?)contact.DisplayNameOverride ?? DBNull.Value);
            cmd.Parameters.AddWithValue("status", (object?)contact.Status ?? DBNull.Value);
            cmd.Parameters.AddWithValue("notes", (object?)contact.Notes ?? DBNull.Value);
            cmd.Parameters.AddWithValue("metadata", (object?)contact.Metadata ?? DBNull.Value);

            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<int> DeleteContactAsync(Guid id)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_contacts_delete(@id);";
            cmd.Parameters.AddWithValue("id", id);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<IEnumerable<GroupRoom>> GetGroupRoomsAllAsync()
        {
            var list = new List<GroupRoom>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_group_rooms_select_all01();";

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(new GroupRoom
                {
                    Id = reader.GetGuid(reader.GetOrdinal("id")),
                    RoomCode = reader.GetString(reader.GetOrdinal("room_code")),
                    Name = reader.GetString(reader.GetOrdinal("name")),
                    Description = GetNullableString(reader, "description"),
                    RoomType = reader.GetString(reader.GetOrdinal("room_type")),
                    CreatedByUserId = GetNullableGuid(reader, "created_by_user_id"),
                    IsActive = reader.GetBoolean(reader.GetOrdinal("is_active")),
                    AvatarUrl = GetNullableString(reader, "avatar_url"),
                    Metadata = GetNullableString(reader, "metadata"),
                    CreatedAt = reader.GetFieldValue<DateTimeOffset>(reader.GetOrdinal("created_at")),
                    UpdatedAt = reader.GetFieldValue<DateTimeOffset>(reader.GetOrdinal("updated_at"))
                });
            }

            return list;
        }

        public async Task<GroupRoom?> GetGroupRoomByIdAsync(Guid id)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_group_rooms_select_details01(@id);";
            cmd.Parameters.AddWithValue("id", id);

            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;

            return new GroupRoom
            {
                Id = reader.GetGuid(reader.GetOrdinal("id")),
                RoomCode = reader.GetString(reader.GetOrdinal("room_code")),
                Name = reader.GetString(reader.GetOrdinal("name")),
                Description = GetNullableString(reader, "description"),
                RoomType = reader.GetString(reader.GetOrdinal("room_type")),
                CreatedByUserId = GetNullableGuid(reader, "created_by_user_id"),
                IsActive = reader.GetBoolean(reader.GetOrdinal("is_active")),
                AvatarUrl = GetNullableString(reader, "avatar_url"),
                Metadata = GetNullableString(reader, "metadata"),
                CreatedAt = reader.GetFieldValue<DateTimeOffset>(reader.GetOrdinal("created_at")),
                UpdatedAt = reader.GetFieldValue<DateTimeOffset>(reader.GetOrdinal("updated_at"))
            };
        }

        public async Task<Guid> InsertGroupRoomAsync(GroupRoom room)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
                        cmd.CommandText = "SELECT public.usp_group_rooms_insert(@room_code, @name, @description, @room_type, @created_by_user_id, @is_active, @avatar_url, @metadata::jsonb, @created_at, @updated_at);";

            cmd.Parameters.AddWithValue("room_code", (object?)room.RoomCode ?? DBNull.Value);
            cmd.Parameters.AddWithValue("name", (object?)room.Name ?? DBNull.Value);
            cmd.Parameters.AddWithValue("description", (object?)room.Description ?? DBNull.Value);
            cmd.Parameters.AddWithValue("room_type", (object?)room.RoomType ?? DBNull.Value);
            cmd.Parameters.AddWithValue("created_by_user_id", (object?)room.CreatedByUserId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("is_active", room.IsActive);
            cmd.Parameters.AddWithValue("avatar_url", (object?)room.AvatarUrl ?? DBNull.Value);
            cmd.Parameters.AddWithValue("metadata", (object?)room.Metadata ?? DBNull.Value);
            cmd.Parameters.AddWithValue("created_at", (object?)room.CreatedAt == default ? DBNull.Value : room.CreatedAt);
            cmd.Parameters.AddWithValue("updated_at", (object?)room.UpdatedAt == default ? DBNull.Value : room.UpdatedAt);

            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? Guid.Empty : (Guid)res;
        }

        public async Task<int> UpdateGroupRoomAsync(GroupRoom room)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_group_rooms_update(@id, @room_code, @name, @description, @room_type, @created_by_user_id, @is_active, @avatar_url, @metadata::jsonb);";

            cmd.Parameters.AddWithValue("id", room.Id);
            cmd.Parameters.AddWithValue("room_code", (object?)room.RoomCode ?? DBNull.Value);
            cmd.Parameters.AddWithValue("name", (object?)room.Name ?? DBNull.Value);
            cmd.Parameters.AddWithValue("description", (object?)room.Description ?? DBNull.Value);
            cmd.Parameters.AddWithValue("room_type", (object?)room.RoomType ?? DBNull.Value);
            cmd.Parameters.AddWithValue("created_by_user_id", (object?)room.CreatedByUserId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("is_active", room.IsActive);
            cmd.Parameters.AddWithValue("avatar_url", (object?)room.AvatarUrl ?? DBNull.Value);
            cmd.Parameters.AddWithValue("metadata", (object?)room.Metadata ?? DBNull.Value);

            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<int> DeleteGroupRoomAsync(Guid id)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_group_rooms_delete(@id);";
            cmd.Parameters.AddWithValue("id", id);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<IEnumerable<GroupRoomMember>> GetGroupRoomMembersAllAsync()
        {
            var list = new List<GroupRoomMember>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_group_room_members_select_all01();";

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(new GroupRoomMember
                {
                    Id = reader.GetGuid(reader.GetOrdinal("id")),
                    RoomId = reader.GetGuid(reader.GetOrdinal("room_id")),
                    UserId = reader.GetGuid(reader.GetOrdinal("user_id")),
                    Role = reader.GetString(reader.GetOrdinal("role")),
                    Nickname = GetNullableString(reader, "nickname"),
                    Status = reader.GetString(reader.GetOrdinal("status")),
                    NotificationsEnabled = reader.GetBoolean(reader.GetOrdinal("notifications_enabled")),
                    JoinedAt = reader.GetFieldValue<DateTimeOffset>(reader.GetOrdinal("joined_at")),
                    LeftAt = GetNullableDateTimeOffset(reader, "left_at"),
                    LastReadAt = GetNullableDateTimeOffset(reader, "last_read_at")
                });
            }

            return list;
        }

        public async Task<GroupRoomMember?> GetGroupRoomMemberByIdAsync(Guid id)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_group_room_members_select_details01(@id);";
            cmd.Parameters.AddWithValue("id", id);

            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;

            return new GroupRoomMember
            {
                Id = reader.GetGuid(reader.GetOrdinal("id")),
                RoomId = reader.GetGuid(reader.GetOrdinal("room_id")),
                UserId = reader.GetGuid(reader.GetOrdinal("user_id")),
                Role = reader.GetString(reader.GetOrdinal("role")),
                Nickname = GetNullableString(reader, "nickname"),
                Status = reader.GetString(reader.GetOrdinal("status")),
                NotificationsEnabled = reader.GetBoolean(reader.GetOrdinal("notifications_enabled")),
                JoinedAt = reader.GetFieldValue<DateTimeOffset>(reader.GetOrdinal("joined_at")),
                LeftAt = GetNullableDateTimeOffset(reader, "left_at"),
                LastReadAt = GetNullableDateTimeOffset(reader, "last_read_at")
            };
        }

        public async Task<Guid> InsertGroupRoomMemberAsync(GroupRoomMember member)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
                        cmd.CommandText = "SELECT public.usp_group_room_members_insert(@room_id, @user_id, @role, @nickname, @status, @notifications_enabled, @joined_at, @left_at, @last_read_at);";

            cmd.Parameters.AddWithValue("room_id", member.RoomId);
            cmd.Parameters.AddWithValue("user_id", member.UserId);
            cmd.Parameters.AddWithValue("role", (object?)member.Role ?? DBNull.Value);
            cmd.Parameters.AddWithValue("nickname", (object?)member.Nickname ?? DBNull.Value);
            cmd.Parameters.AddWithValue("status", (object?)member.Status ?? DBNull.Value);
            cmd.Parameters.AddWithValue("notifications_enabled", member.NotificationsEnabled);
            cmd.Parameters.AddWithValue("joined_at", member.JoinedAt == default ? DBNull.Value : member.JoinedAt);
            cmd.Parameters.AddWithValue("left_at", (object?)member.LeftAt ?? DBNull.Value);
            cmd.Parameters.AddWithValue("last_read_at", (object?)member.LastReadAt ?? DBNull.Value);

            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? Guid.Empty : (Guid)res;
        }

        public async Task<int> UpdateGroupRoomMemberAsync(GroupRoomMember member)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_group_room_members_update(@id, @room_id, @user_id, @role, @nickname, @status, @notifications_enabled, @joined_at, @left_at, @last_read_at);";

            cmd.Parameters.AddWithValue("id", member.Id);
            cmd.Parameters.AddWithValue("room_id", member.RoomId);
            cmd.Parameters.AddWithValue("user_id", member.UserId);
            cmd.Parameters.AddWithValue("role", (object?)member.Role ?? DBNull.Value);
            cmd.Parameters.AddWithValue("nickname", (object?)member.Nickname ?? DBNull.Value);
            cmd.Parameters.AddWithValue("status", (object?)member.Status ?? DBNull.Value);
            cmd.Parameters.AddWithValue("notifications_enabled", member.NotificationsEnabled);
            cmd.Parameters.AddWithValue("joined_at", member.JoinedAt == default ? DBNull.Value : member.JoinedAt);
            cmd.Parameters.AddWithValue("left_at", (object?)member.LeftAt ?? DBNull.Value);
            cmd.Parameters.AddWithValue("last_read_at", (object?)member.LastReadAt ?? DBNull.Value);

            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<int> DeleteGroupRoomMemberAsync(Guid id)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_group_room_members_delete(@id);";
            cmd.Parameters.AddWithValue("id", id);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        private static string? GetNullableString(NpgsqlDataReader reader, string column)
        {
            var idx = reader.GetOrdinal(column);
            return reader.IsDBNull(idx) ? null : reader.GetString(idx);
        }

        private static long? GetNullableLong(NpgsqlDataReader reader, string column)
        {
            var idx = reader.GetOrdinal(column);
            return reader.IsDBNull(idx) ? null : reader.GetInt64(idx);
        }

        private static Guid? GetNullableGuid(NpgsqlDataReader reader, string column)
        {
            var idx = reader.GetOrdinal(column);
            return reader.IsDBNull(idx) ? null : reader.GetGuid(idx);
        }

        private static bool GetBoolDefaultFalse(NpgsqlDataReader reader, string column)
        {
            var idx = reader.GetOrdinal(column);
            return reader.IsDBNull(idx) ? false : reader.GetBoolean(idx);
        }

        private static DateTime? GetNullableDateTime(NpgsqlDataReader reader, string column)
        {
            var idx = reader.GetOrdinal(column);
            if (reader.IsDBNull(idx)) return null;
            try
            {
                var value = reader.GetFieldValue<DateTime>(idx);
                return value.Kind == DateTimeKind.Utc
                    ? value
                    : DateTime.SpecifyKind(value, DateTimeKind.Utc);
            }
            catch
            {
                return null;
            }
        }

        private static DateTimeOffset? GetNullableDateTimeOffset(NpgsqlDataReader reader, string column)
        {
            var idx = reader.GetOrdinal(column);
            return reader.IsDBNull(idx) ? null : reader.GetFieldValue<DateTimeOffset>(idx);
        }
    }
}

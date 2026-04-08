using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.Communication.DTOs;
using ConfidantPostgreSQL.Modules.Communication.Models;

namespace ConfidantPostgreSQL.Modules.Communication.Service
{
    public interface ICommunicationService
    {
        Task<IEnumerable<Notification>> GetNotificationsAllAsync();
        Task<Notification?> GetNotificationByIdAsync(Guid idNotification);
        Task<Guid> InsertNotificationAsync(Notification notification);
        Task<int> UpdateNotificationAsync(Notification notification);
        Task<int> DeleteNotificationAsync(Guid idNotification);

        Task<IEnumerable<Message>> GetMessagesAllAsync();
        Task<Message?> GetMessageByIdAsync(Guid idMessage);
        Task<Guid> InsertMessageAsync(Message message);
        Task<int> UpdateMessageAsync(Message message);
        Task<int> DeleteMessageAsync(Guid idMessage);

        Task<IEnumerable<Contact>> GetContactsAllAsync();
        Task<IEnumerable<Contact>> GetContactsByOwnerAsync(Guid ownerUserId);
        Task<Contact?> GetContactByOwnerAndContactAsync(Guid ownerUserId, Guid contactUserId);
        Task<Contact?> GetContactByIdAsync(Guid id);
        Task<Guid> InsertContactAsync(Contact contact);
        Task<Guid> UpsertContactAsync(Contact contact);
        Task<int> UpdateContactAsync(Contact contact);
        Task<int> DeleteContactAsync(Guid id);

        Task<IEnumerable<ContactUserSummary>> GetContactUserSummariesByOwnerAsync(Guid ownerUserId);

        Task<IEnumerable<GroupRoom>> GetGroupRoomsAllAsync();
        Task<GroupRoom?> GetGroupRoomByIdAsync(Guid id);
        Task<Guid> InsertGroupRoomAsync(GroupRoom room);
        Task<int> UpdateGroupRoomAsync(GroupRoom room);
        Task<int> DeleteGroupRoomAsync(Guid id);

        Task<IEnumerable<GroupRoomMember>> GetGroupRoomMembersAllAsync();
        Task<GroupRoomMember?> GetGroupRoomMemberByIdAsync(Guid id);
        Task<Guid> InsertGroupRoomMemberAsync(GroupRoomMember member);
        Task<int> UpdateGroupRoomMemberAsync(GroupRoomMember member);
        Task<int> DeleteGroupRoomMemberAsync(Guid id);
    }
}

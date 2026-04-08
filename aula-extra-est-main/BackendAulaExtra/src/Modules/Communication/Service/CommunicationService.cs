using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.Communication.DTOs;
using ConfidantPostgreSQL.Modules.Communication.Models;
using ConfidantPostgreSQL.Modules.Communication.Repository;

namespace ConfidantPostgreSQL.Modules.Communication.Service
{
    public class CommunicationService : ICommunicationService
    {
        private readonly ICommunicationRepository _repo;

        public CommunicationService(ICommunicationRepository repo)
        {
            _repo = repo;
        }

        public Task<IEnumerable<Notification>> GetNotificationsAllAsync() => _repo.GetNotificationsAllAsync();
        public Task<Notification?> GetNotificationByIdAsync(Guid idNotification) => _repo.GetNotificationByIdAsync(idNotification);
        public Task<Guid> InsertNotificationAsync(Notification notification) => _repo.InsertNotificationAsync(notification);
        public Task<int> UpdateNotificationAsync(Notification notification) => _repo.UpdateNotificationAsync(notification);
        public Task<int> DeleteNotificationAsync(Guid idNotification) => _repo.DeleteNotificationAsync(idNotification);

        public Task<IEnumerable<Message>> GetMessagesAllAsync() => _repo.GetMessagesAllAsync();
        public Task<Message?> GetMessageByIdAsync(Guid idMessage) => _repo.GetMessageByIdAsync(idMessage);
        public Task<Guid> InsertMessageAsync(Message message) => _repo.InsertMessageAsync(message);
        public Task<int> UpdateMessageAsync(Message message) => _repo.UpdateMessageAsync(message);
        public Task<int> DeleteMessageAsync(Guid idMessage) => _repo.DeleteMessageAsync(idMessage);

        public Task<IEnumerable<Contact>> GetContactsAllAsync() => _repo.GetContactsAllAsync();
        public Task<IEnumerable<Contact>> GetContactsByOwnerAsync(Guid ownerUserId) => _repo.GetContactsByOwnerAsync(ownerUserId);
        public Task<Contact?> GetContactByOwnerAndContactAsync(Guid ownerUserId, Guid contactUserId) => _repo.GetContactByOwnerAndContactAsync(ownerUserId, contactUserId);
        public Task<Contact?> GetContactByIdAsync(Guid id) => _repo.GetContactByIdAsync(id);
        public Task<Guid> InsertContactAsync(Contact contact) => _repo.InsertContactAsync(contact);
        public Task<Guid> UpsertContactAsync(Contact contact) => _repo.UpsertContactAsync(contact);
        public Task<int> UpdateContactAsync(Contact contact) => _repo.UpdateContactAsync(contact);
        public Task<int> DeleteContactAsync(Guid id) => _repo.DeleteContactAsync(id);

        public Task<IEnumerable<ContactUserSummary>> GetContactUserSummariesByOwnerAsync(Guid ownerUserId) => _repo.GetContactUserSummariesByOwnerAsync(ownerUserId);

        public Task<IEnumerable<GroupRoom>> GetGroupRoomsAllAsync() => _repo.GetGroupRoomsAllAsync();
        public Task<GroupRoom?> GetGroupRoomByIdAsync(Guid id) => _repo.GetGroupRoomByIdAsync(id);
        public Task<Guid> InsertGroupRoomAsync(GroupRoom room) => _repo.InsertGroupRoomAsync(room);
        public Task<int> UpdateGroupRoomAsync(GroupRoom room) => _repo.UpdateGroupRoomAsync(room);
        public Task<int> DeleteGroupRoomAsync(Guid id) => _repo.DeleteGroupRoomAsync(id);

        public Task<IEnumerable<GroupRoomMember>> GetGroupRoomMembersAllAsync() => _repo.GetGroupRoomMembersAllAsync();
        public Task<GroupRoomMember?> GetGroupRoomMemberByIdAsync(Guid id) => _repo.GetGroupRoomMemberByIdAsync(id);
        public Task<Guid> InsertGroupRoomMemberAsync(GroupRoomMember member) => _repo.InsertGroupRoomMemberAsync(member);
        public Task<int> UpdateGroupRoomMemberAsync(GroupRoomMember member) => _repo.UpdateGroupRoomMemberAsync(member);
        public Task<int> DeleteGroupRoomMemberAsync(Guid id) => _repo.DeleteGroupRoomMemberAsync(id);
    }
}

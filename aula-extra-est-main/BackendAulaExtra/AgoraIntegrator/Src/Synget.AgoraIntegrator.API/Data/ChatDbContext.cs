using Microsoft.EntityFrameworkCore;
using Synget.AgoraIntegrator.API.Data.Entities;

namespace Synget.AgoraIntegrator.API.Data;

/// <summary>
/// EF Core DbContext for chat persistence (users, messages, contacts, rooms, calls, professor rooms).
/// </summary>
public class ChatDbContext : DbContext
{
    public ChatDbContext(DbContextOptions<ChatDbContext> options) : base(options)
    {
    }

    public DbSet<UserEntity> Users => Set<UserEntity>();
    public DbSet<MessageEntity> Messages => Set<MessageEntity>();
    public DbSet<ContactEntity> Contacts => Set<ContactEntity>();
    public DbSet<GroupRoomEntity> GroupRooms => Set<GroupRoomEntity>();
    public DbSet<GroupRoomMemberEntity> GroupRoomMembers => Set<GroupRoomMemberEntity>();
    public DbSet<VideoCallEntity> VideoCalls => Set<VideoCallEntity>();
    public DbSet<VideoCallParticipantEntity> VideoCallParticipants => Set<VideoCallParticipantEntity>();
    public DbSet<SessionEntity> Sessions => Set<SessionEntity>();
    public DbSet<VideoRoomEntity> VideoRooms => Set<VideoRoomEntity>();
    public DbSet<VideoRoomParticipantEntity> VideoRoomParticipants => Set<VideoRoomParticipantEntity>();
    public DbSet<ProfessorRoomEntity> ProfessorRooms => Set<ProfessorRoomEntity>();
    public DbSet<ChatFileEntity> ChatFiles => Set<ChatFileEntity>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Users configuration
        modelBuilder.Entity<UserEntity>(entity =>
        {
            entity.HasIndex(e => e.Username).IsUnique();
            entity.HasIndex(e => e.Email).IsUnique();
        });

        // Messages configuration
        modelBuilder.Entity<MessageEntity>(entity =>
        {
                  entity.HasIndex(e => e.CreatedAt);
            entity.HasIndex(e => e.SenderUserId);
            entity.HasIndex(e => e.ReceiverUserId);
            entity.HasIndex(e => e.GroupRoomId);

            entity.HasOne(m => m.SenderUser)
                  .WithMany(u => u.SentMessages)
                  .HasForeignKey(m => m.SenderUserId)
                  .OnDelete(DeleteBehavior.Cascade);

            entity.HasOne(m => m.ReceiverUser)
                  .WithMany(u => u.ReceivedMessages)
                  .HasForeignKey(m => m.ReceiverUserId)
                  .OnDelete(DeleteBehavior.Cascade);

            entity.HasOne(m => m.GroupRoom)
                  .WithMany(r => r.Messages)
                  .HasForeignKey(m => m.GroupRoomId)
                  .OnDelete(DeleteBehavior.SetNull);
        });

        // Contacts configuration
        modelBuilder.Entity<ContactEntity>(entity =>
        {
            entity.HasIndex(e => e.OwnerUserId);
            entity.HasIndex(e => e.ContactUserId);
            entity.HasIndex(e => e.Status);
            entity.HasIndex(e => new { e.OwnerUserId, e.ContactUserId }).IsUnique();

            entity.HasOne(c => c.OwnerUser)
                  .WithMany(u => u.Contacts)
                  .HasForeignKey(c => c.OwnerUserId)
                  .OnDelete(DeleteBehavior.Cascade);

            entity.HasOne(c => c.ContactUser)
                  .WithMany(u => u.ContactOf)
                  .HasForeignKey(c => c.ContactUserId)
                  .OnDelete(DeleteBehavior.Cascade);
        });

        // Group rooms configuration
        modelBuilder.Entity<GroupRoomEntity>(entity =>
        {
            entity.HasIndex(e => e.RoomCode).IsUnique();
            entity.HasIndex(e => e.CreatedByUserId);
            entity.HasIndex(e => e.IsActive);

            entity.HasOne(r => r.CreatedByUser)
                  .WithMany()
                  .HasForeignKey(r => r.CreatedByUserId)
                  .OnDelete(DeleteBehavior.SetNull);
        });

        // Group room members configuration
        modelBuilder.Entity<GroupRoomMemberEntity>(entity =>
        {
            entity.HasIndex(e => e.RoomId);
            entity.HasIndex(e => e.UserId);
            entity.HasIndex(e => e.Status);
            entity.HasIndex(e => new { e.RoomId, e.UserId }).IsUnique();

            entity.HasOne(m => m.Room)
                  .WithMany(r => r.Members)
                  .HasForeignKey(m => m.RoomId)
                  .OnDelete(DeleteBehavior.Cascade);

            entity.HasOne(m => m.User)
                  .WithMany(u => u.RoomMemberships)
                  .HasForeignKey(m => m.UserId)
                  .OnDelete(DeleteBehavior.Cascade);
        });

        // Video calls configuration
        modelBuilder.Entity<VideoCallEntity>(entity =>
        {
            entity.HasIndex(e => e.ChannelName);
            entity.HasIndex(e => e.GroupRoomId);
            entity.HasIndex(e => e.InitiatedByUserId);
            entity.HasIndex(e => e.Status);
            entity.HasIndex(e => e.StartedAt);

            entity.HasOne(c => c.GroupRoom)
                  .WithMany(r => r.VideoCalls)
                  .HasForeignKey(c => c.GroupRoomId)
                  .OnDelete(DeleteBehavior.SetNull);

            entity.HasOne(c => c.InitiatedByUser)
                  .WithMany()
                  .HasForeignKey(c => c.InitiatedByUserId)
                  .OnDelete(DeleteBehavior.SetNull);
        });

        // Video call participants configuration
        modelBuilder.Entity<VideoCallParticipantEntity>(entity =>
        {
            entity.HasIndex(e => e.CallId);
            entity.HasIndex(e => e.UserId);
            entity.HasIndex(e => e.JoinedAt);

            entity.HasOne(p => p.Call)
                  .WithMany(c => c.Participants)
                  .HasForeignKey(p => p.CallId)
                  .OnDelete(DeleteBehavior.Cascade);

            entity.HasOne(p => p.User)
                  .WithMany(u => u.CallParticipations)
                  .HasForeignKey(p => p.UserId)
                  .OnDelete(DeleteBehavior.Cascade);
        });

        // Sessions configuration
        modelBuilder.Entity<SessionEntity>(entity =>
        {
            entity.HasIndex(e => e.Token).IsUnique();
            entity.HasIndex(e => e.UserId);
            entity.HasIndex(e => e.ExpiresAt);

            entity.HasOne(s => s.User)
                  .WithMany()
                  .HasForeignKey(s => s.UserId)
                  .OnDelete(DeleteBehavior.Cascade);
        });

        // Video rooms configuration (for role-based video calls)
        modelBuilder.Entity<VideoRoomEntity>(entity =>
        {
            entity.HasIndex(e => e.ChannelName).IsUnique();
            entity.HasIndex(e => e.HostUserId);
            entity.HasIndex(e => e.IsActive);

            entity.HasOne(r => r.Host)
                  .WithMany()
                  .HasForeignKey(r => r.HostUserId)
                  .OnDelete(DeleteBehavior.Cascade);
        });

        // Video room participants configuration
        modelBuilder.Entity<VideoRoomParticipantEntity>(entity =>
        {
            entity.HasIndex(e => e.VideoRoomId);
            entity.HasIndex(e => e.UserId);
            entity.HasIndex(e => new { e.VideoRoomId, e.UserId }).IsUnique();

            entity.HasOne(p => p.VideoRoom)
                  .WithMany(r => r.Participants)
                  .HasForeignKey(p => p.VideoRoomId)
                  .OnDelete(DeleteBehavior.Cascade);

            entity.HasOne(p => p.User)
                  .WithMany()
                  .HasForeignKey(p => p.UserId)
                  .OnDelete(DeleteBehavior.Cascade);
        });

        // Professor rooms configuration
        modelBuilder.Entity<ProfessorRoomEntity>(entity =>
        {
            entity.HasIndex(e => e.ProfessorId).IsUnique();
            entity.HasIndex(e => e.RoomName).IsUnique();
            entity.HasIndex(e => e.IsActive);

            entity.HasOne(r => r.Professor)
                  .WithOne()
                  .HasForeignKey<ProfessorRoomEntity>(r => r.ProfessorId)
                  .OnDelete(DeleteBehavior.Cascade);
        });

        // Chat files configuration
        modelBuilder.Entity<ChatFileEntity>(entity =>
        {
            entity.HasIndex(e => e.FileId).IsUnique();
            entity.HasIndex(e => e.UploadedByUserId);
            entity.HasIndex(e => e.RoomId);
            entity.HasIndex(e => e.MessageId);
            entity.HasIndex(e => e.IsActive);

            entity.HasOne(f => f.UploadedByUser)
                  .WithMany()
                  .HasForeignKey(f => f.UploadedByUserId)
                  .OnDelete(DeleteBehavior.SetNull);

            entity.HasOne(f => f.Message)
                  .WithMany()
                  .HasForeignKey(f => f.MessageId)
                  .OnDelete(DeleteBehavior.SetNull);
        });
    }
}

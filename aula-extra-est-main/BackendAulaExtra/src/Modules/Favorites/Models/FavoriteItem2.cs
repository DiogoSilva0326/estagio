using System;
namespace ConfidantPostgreSQL.Modules.Favorites.Models
{
    public class FavoriteItem2
    {
        public Guid FavoriteItemId {get; set;}
        public Guid FavoriteId {get; set;}
        public Guid ProfessorId {get; set;}
        public DateTime? AddedAt {get; set;}
    }
}
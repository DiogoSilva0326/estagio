using System;

namespace ConfidantPostgreSQL.Modules.Favorites.Models
{
    public class FavoriteItem
    {
        public Guid IdFavoriteItem { get; set; }
        public Guid IdFavorite { get; set; }
        public Guid IdProfessor { get; set; }
        public DateTime? AddedAt { get; set; }
    }
}

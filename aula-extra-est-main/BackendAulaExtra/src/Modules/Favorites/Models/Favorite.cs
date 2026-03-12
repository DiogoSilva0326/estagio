using System;

namespace ConfidantPostgreSQL.Modules.Favorites.Models
{
    public class Favorite
    {
        public Guid IdFavorite { get; set; }
        public Guid IdUser { get; set; }
        public DateTime? CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
    }
}

using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.Favorites.Models;

namespace ConfidantPostgreSQL.Modules.Favorites.Repository
{
    public interface IFavoritesRepository
    {
        Task<IEnumerable<Wishlist>> GetWishlistsAllAsync();
        Task<Wishlist?> GetWishlistByIdAsync(Guid idWishlist);
        Task<Guid> InsertWishlistAsync(Wishlist wishlist);
        Task<int> UpdateWishlistAsync(Wishlist wishlist);
        Task<int> DeleteWishlistAsync(Guid idWishlist);

        Task<IEnumerable<WishlistItem>> GetWishlistItemsAllAsync();
        Task<WishlistItem?> GetWishlistItemByIdAsync(Guid idWishlistItem);
        Task<Guid> InsertWishlistItemAsync(WishlistItem item);
        Task<int> UpdateWishlistItemAsync(WishlistItem item);
        Task<int> DeleteWishlistItemAsync(Guid idWishlistItem);

        Task<IEnumerable<Favorite>> GetFavoritesAllAsync();
        Task<Favorite?> GetFavoriteByIdAsync(Guid idFavorite);
        Task<Guid> InsertFavoriteAsync(Favorite favorite);
        Task<int> UpdateFavoriteAsync(Favorite favorite);
        Task<int> DeleteFavoriteAsync(Guid idFavorite);

        Task<IEnumerable<FavoriteItem>> GetFavoriteItemsAllAsync();
        Task<FavoriteItem?> GetFavoriteItemByIdAsync(Guid idFavoriteItem);
        Task<Guid> InsertFavoriteItemAsync(FavoriteItem item);
        Task<int> UpdateFavoriteItemAsync(FavoriteItem item);
        Task<int> DeleteFavoriteItemAsync(Guid idFavoriteItem);
    }
}

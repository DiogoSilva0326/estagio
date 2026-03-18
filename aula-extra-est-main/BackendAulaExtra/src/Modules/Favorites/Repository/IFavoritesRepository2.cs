using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.Favorites.Models;

namespace ConfidantPostgreSQL.Modules.Favorites.Repository
{
    public interface IFavoritesRepository2
    {
        Task<IEnumerable<Favorite2>> GetFavoritesAllAsync();
        Task<Favorite2?> GetFavoriteByIdAsync(Guid idFavorite2);
        Task<Guid> InsertFavoriteAsync(Favorite2 favorite2);
        Task<int> UpdateFavoriteAsync(Favorite2 favorite2);
        Task<int> DeleteFavoriteAsync(Guid favorite2);

        Task<IEnumerable<FavoriteItem2>> GetFavoriteItemsAllAsync();
        Task<FavoriteItem2?> GetFavoriteItemByIdAsync(Guid idIavoriteItem2);
        Task<Guid> InsertFavoriteItemAsync(FavoriteItem2 item);
        Task<int> UpdateFavoriteItemAsync(FavoriteItem2 item);
        Task<int> DeleteFavoriteItemAsync(Guid idfavoriteItem2);

        Task<IEnumerable<Wishlist2>> GetWishlistsAllAsync();
        Task<Wishlist2?> GetWishlistByIdAsync(Guid idWishlist);
        Task<Guid> InsertWishlistAsync(Wishlist2 wishlist);
        Task<int> UpdateWishlist(Wishlist2 wishlist);
        Task<int> DeleteWishlist(Guid idWishlist);

        Task<IEnumerable<WishlistItem2>> GetWishlistItemsAllAsync();
        Task<WishlistItem2?> GetWishlistByIdAsync(Guid idWishlistItem);
        Task<Guid> InsertWishlistItemAsync(WishlistItem2 wishlistItem);
        Task<int> UpdateWishlistItemAsync(WishlistItem2 wishlistItem2);
        Task<int> DeleteWishlistItemAsync(Guid idWishlistItem);
    }
}
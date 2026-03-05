using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.Favorites.Models;
using ConfidantPostgreSQL.Modules.Favorites.Repository;

namespace ConfidantPostgreSQL.Modules.Favorites.Service
{
    public class FavoritesService : IFavoritesService
    {
        private readonly IFavoritesRepository _repo;

        public FavoritesService(IFavoritesRepository repo)
        {
            _repo = repo;
        }

        public Task<IEnumerable<Wishlist>> GetWishlistsAllAsync() => _repo.GetWishlistsAllAsync();
        public Task<Wishlist?> GetWishlistByIdAsync(Guid idWishlist) => _repo.GetWishlistByIdAsync(idWishlist);
        public Task<Guid> InsertWishlistAsync(Wishlist wishlist) => _repo.InsertWishlistAsync(wishlist);
        public Task<int> UpdateWishlistAsync(Wishlist wishlist) => _repo.UpdateWishlistAsync(wishlist);
        public Task<int> DeleteWishlistAsync(Guid idWishlist) => _repo.DeleteWishlistAsync(idWishlist);

        public Task<IEnumerable<WishlistItem>> GetWishlistItemsAllAsync() => _repo.GetWishlistItemsAllAsync();
        public Task<WishlistItem?> GetWishlistItemByIdAsync(Guid idWishlistItem) => _repo.GetWishlistItemByIdAsync(idWishlistItem);
        public Task<Guid> InsertWishlistItemAsync(WishlistItem item) => _repo.InsertWishlistItemAsync(item);
        public Task<int> UpdateWishlistItemAsync(WishlistItem item) => _repo.UpdateWishlistItemAsync(item);
        public Task<int> DeleteWishlistItemAsync(Guid idWishlistItem) => _repo.DeleteWishlistItemAsync(idWishlistItem);

        public Task<IEnumerable<Favorite>> GetFavoritesAllAsync() => _repo.GetFavoritesAllAsync();
        public Task<Favorite?> GetFavoriteByIdAsync(Guid idFavorite) => _repo.GetFavoriteByIdAsync(idFavorite);
        public Task<Guid> InsertFavoriteAsync(Favorite favorite) => _repo.InsertFavoriteAsync(favorite);
        public Task<int> UpdateFavoriteAsync(Favorite favorite) => _repo.UpdateFavoriteAsync(favorite);
        public Task<int> DeleteFavoriteAsync(Guid idFavorite) => _repo.DeleteFavoriteAsync(idFavorite);

        public Task<IEnumerable<FavoriteItem>> GetFavoriteItemsAllAsync() => _repo.GetFavoriteItemsAllAsync();
        public Task<FavoriteItem?> GetFavoriteItemByIdAsync(Guid idFavoriteItem) => _repo.GetFavoriteItemByIdAsync(idFavoriteItem);
        public Task<Guid> InsertFavoriteItemAsync(FavoriteItem item) => _repo.InsertFavoriteItemAsync(item);
        public Task<int> UpdateFavoriteItemAsync(FavoriteItem item) => _repo.UpdateFavoriteItemAsync(item);
        public Task<int> DeleteFavoriteItemAsync(Guid idFavoriteItem) => _repo.DeleteFavoriteItemAsync(idFavoriteItem);
    }
}

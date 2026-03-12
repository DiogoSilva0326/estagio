using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.Favorites.Models;
using Npgsql;

namespace ConfidantPostgreSQL.Modules.Favorites.Repository
{
    public class FavoritesRepository : IFavoritesRepository
    {
        private readonly string _connectionString;

        public FavoritesRepository(string connectionString)
        {
            _connectionString = connectionString;
        }

        public async Task<IEnumerable<Wishlist>> GetWishlistsAllAsync()
        {
            var list = new List<Wishlist>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_wishlists_select_all01();";
            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(new Wishlist
                {
                    IdWishlist = reader.GetGuid(reader.GetOrdinal("id_wishlist")),
                    IdUser = reader.GetGuid(reader.GetOrdinal("id_user")),
                    CreatedAt = GetNullableDateTime(reader, "created_at")
                });
            }
            return list;
        }

        public async Task<Wishlist?> GetWishlistByIdAsync(Guid idWishlist)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_wishlists_select_details01(@id_wishlist);";
            cmd.Parameters.AddWithValue("id_wishlist", idWishlist);
            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;
            return new Wishlist
            {
                IdWishlist = reader.GetGuid(reader.GetOrdinal("id_wishlist")),
                IdUser = reader.GetGuid(reader.GetOrdinal("id_user")),
                CreatedAt = GetNullableDateTime(reader, "created_at")
            };
        }

        public async Task<Guid> InsertWishlistAsync(Wishlist wishlist)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_wishlists_insert(@id_user, @created_at);";
            cmd.Parameters.AddWithValue("id_user", wishlist.IdUser);
            cmd.Parameters.AddWithValue("created_at", (object?)wishlist.CreatedAt ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? Guid.Empty : (Guid)res;
        }

        public async Task<int> UpdateWishlistAsync(Wishlist wishlist)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_wishlists_update(@id_wishlist, @id_user);";
            cmd.Parameters.AddWithValue("id_wishlist", wishlist.IdWishlist);
            cmd.Parameters.AddWithValue("id_user", wishlist.IdUser);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<int> DeleteWishlistAsync(Guid idWishlist)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_wishlists_delete(@id_wishlist);";
            cmd.Parameters.AddWithValue("id_wishlist", idWishlist);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<IEnumerable<WishlistItem>> GetWishlistItemsAllAsync()
        {
            var list = new List<WishlistItem>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_wishlist_items_select_all01();";
            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(new WishlistItem
                {
                    IdWishlistItem = reader.GetGuid(reader.GetOrdinal("id_wishlist_item")),
                    IdWishlist = reader.GetGuid(reader.GetOrdinal("id_wishlist")),
                    CourseId = GetNullableGuid(reader, "course_id"),
                    AddedAt = GetNullableDateTime(reader, "added_at")
                });
            }
            return list;
        }

        public async Task<WishlistItem?> GetWishlistItemByIdAsync(Guid idWishlistItem)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_wishlist_items_select_details01(@id_wishlist_item);";
            cmd.Parameters.AddWithValue("id_wishlist_item", idWishlistItem);
            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;
            return new WishlistItem
            {
                IdWishlistItem = reader.GetGuid(reader.GetOrdinal("id_wishlist_item")),
                IdWishlist = reader.GetGuid(reader.GetOrdinal("id_wishlist")),
                CourseId = GetNullableGuid(reader, "course_id"),
                AddedAt = GetNullableDateTime(reader, "added_at")
            };
        }

        public async Task<Guid> InsertWishlistItemAsync(WishlistItem item)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_wishlist_items_insert(@id_wishlist, @course_id, @added_at);";
            cmd.Parameters.AddWithValue("id_wishlist", item.IdWishlist);
            cmd.Parameters.AddWithValue("course_id", (object?)item.CourseId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("added_at", (object?)item.AddedAt ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? Guid.Empty : (Guid)res;
        }

        public async Task<int> UpdateWishlistItemAsync(WishlistItem item)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_wishlist_items_update(@id_wishlist_item, @id_wishlist, @course_id, @added_at);";
            cmd.Parameters.AddWithValue("id_wishlist_item", item.IdWishlistItem);
            cmd.Parameters.AddWithValue("id_wishlist", item.IdWishlist);
            cmd.Parameters.AddWithValue("course_id", (object?)item.CourseId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("added_at", (object?)item.AddedAt ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<int> DeleteWishlistItemAsync(Guid idWishlistItem)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_wishlist_items_delete(@id_wishlist_item);";
            cmd.Parameters.AddWithValue("id_wishlist_item", idWishlistItem);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<IEnumerable<Favorite>> GetFavoritesAllAsync()
        {
            var list = new List<Favorite>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_favorites_select_all01();";
            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(new Favorite
                {
                    IdFavorite = reader.GetGuid(reader.GetOrdinal("id_favorite")),
                    IdUser = reader.GetGuid(reader.GetOrdinal("id_user")),
                    CreatedAt = GetNullableDateTime(reader, "created_at"),
                    UpdatedAt = GetNullableDateTime(reader, "updated_at")
                });
            }
            return list;
        }

        public async Task<Favorite?> GetFavoriteByIdAsync(Guid idFavorite)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_favorites_select_details01(@id_favorite);";
            cmd.Parameters.AddWithValue("id_favorite", idFavorite);
            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;
            return new Favorite
            {
                IdFavorite = reader.GetGuid(reader.GetOrdinal("id_favorite")),
                IdUser = reader.GetGuid(reader.GetOrdinal("id_user")),
                CreatedAt = GetNullableDateTime(reader, "created_at"),
                UpdatedAt = GetNullableDateTime(reader, "updated_at")
            };
        }

        public async Task<Guid> InsertFavoriteAsync(Favorite favorite)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_favorites_insert(@id_user, @created_at, @updated_at);";
            cmd.Parameters.AddWithValue("id_user", favorite.IdUser);
            cmd.Parameters.AddWithValue("created_at", (object?)favorite.CreatedAt ?? DBNull.Value);
            cmd.Parameters.AddWithValue("updated_at", (object?)favorite.UpdatedAt ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? Guid.Empty : (Guid)res;
        }

        public async Task<int> UpdateFavoriteAsync(Favorite favorite)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_favorites_update(@id_favorite, @id_user);";
            cmd.Parameters.AddWithValue("id_favorite", favorite.IdFavorite);
            cmd.Parameters.AddWithValue("id_user", favorite.IdUser);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<int> DeleteFavoriteAsync(Guid idFavorite)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_favorites_delete(@id_favorite);";
            cmd.Parameters.AddWithValue("id_favorite", idFavorite);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<IEnumerable<FavoriteItem>> GetFavoriteItemsAllAsync()
        {
            var list = new List<FavoriteItem>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_favorite_items_select_all01();";
            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(new FavoriteItem
                {
                    IdFavoriteItem = reader.GetGuid(reader.GetOrdinal("id_favorite_item")),
                    IdFavorite = reader.GetGuid(reader.GetOrdinal("id_favorite")),
                    IdProfessor = reader.GetGuid(reader.GetOrdinal("id_professor")),
                    AddedAt = GetNullableDateTime(reader, "added_at")
                });
            }
            return list;
        }

        public async Task<FavoriteItem?> GetFavoriteItemByIdAsync(Guid idFavoriteItem)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_favorite_items_select_details01(@id_favorite_item);";
            cmd.Parameters.AddWithValue("id_favorite_item", idFavoriteItem);
            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;
            return new FavoriteItem
            {
                IdFavoriteItem = reader.GetGuid(reader.GetOrdinal("id_favorite_item")),
                IdFavorite = reader.GetGuid(reader.GetOrdinal("id_favorite")),
                IdProfessor = reader.GetGuid(reader.GetOrdinal("id_professor")),
                AddedAt = GetNullableDateTime(reader, "added_at")
            };
        }

        public async Task<Guid> InsertFavoriteItemAsync(FavoriteItem item)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_favorite_items_insert(@id_favorite, @id_professor, @added_at);";
            cmd.Parameters.AddWithValue("id_favorite", item.IdFavorite);
            cmd.Parameters.AddWithValue("id_professor", item.IdProfessor);
            cmd.Parameters.AddWithValue("added_at", (object?)item.AddedAt ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? Guid.Empty : (Guid)res;
        }

        public async Task<int> UpdateFavoriteItemAsync(FavoriteItem item)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_favorite_items_update(@id_favorite_item, @id_favorite, @id_professor, @added_at);";
            cmd.Parameters.AddWithValue("id_favorite_item", item.IdFavoriteItem);
            cmd.Parameters.AddWithValue("id_favorite", item.IdFavorite);
            cmd.Parameters.AddWithValue("id_professor", item.IdProfessor);
            cmd.Parameters.AddWithValue("added_at", (object?)item.AddedAt ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<int> DeleteFavoriteItemAsync(Guid idFavoriteItem)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_favorite_items_delete(@id_favorite_item);";
            cmd.Parameters.AddWithValue("id_favorite_item", idFavoriteItem);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        private static Guid? GetNullableGuid(NpgsqlDataReader reader, string column)
        {
            var idx = reader.GetOrdinal(column);
            return reader.IsDBNull(idx) ? null : reader.GetGuid(idx);
        }

        private static DateTime? GetNullableDateTime(NpgsqlDataReader reader, string column)
        {
            var idx = reader.GetOrdinal(column);
            if (reader.IsDBNull(idx)) return null;
            try { return reader.GetFieldValue<DateTime>(idx); } catch { return null; }
        }
    }
}

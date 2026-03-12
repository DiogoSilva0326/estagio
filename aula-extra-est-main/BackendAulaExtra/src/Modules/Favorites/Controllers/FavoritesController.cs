using System;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Auth;
using ConfidantPostgreSQL.Modules.Favorites.Models;
using ConfidantPostgreSQL.Modules.Favorites.Service;
using Microsoft.AspNetCore.Mvc;

namespace ConfidantPostgreSQL.Modules.Favorites.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [AuthorizeJwt]
    public class FavoritesController : ControllerBase
    {
        private readonly IFavoritesService _service;

        public FavoritesController(IFavoritesService service)
        {
            _service = service;
        }

        private bool TryAuthorize(out IActionResult? unauthorized)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            unauthorized = null;
            return true;
        }

        // WISHLISTS
        [HttpGet("wishlists")]
        public async Task<IActionResult> GetWishlists()
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            return Ok(await _service.GetWishlistsAllAsync());
        }

        [HttpGet("wishlists/{idWishlist:guid}")]
        public async Task<IActionResult> GetWishlist(Guid idWishlist)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var item = await _service.GetWishlistByIdAsync(idWishlist);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpPost("wishlists")]
        public async Task<IActionResult> CreateWishlist([FromBody] Wishlist wishlist)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var id = await _service.InsertWishlistAsync(wishlist);
            wishlist.IdWishlist = id;
            return CreatedAtAction(nameof(GetWishlist), new { idWishlist = id }, wishlist);
        }

        [HttpPut("wishlists/{idWishlist:guid}")]
        public async Task<IActionResult> UpdateWishlist(Guid idWishlist, [FromBody] Wishlist wishlist)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            if (idWishlist != wishlist.IdWishlist) return BadRequest();
            var rows = await _service.UpdateWishlistAsync(wishlist);
            return rows == 0 ? NotFound() : NoContent();
        }

        [HttpDelete("wishlists/{idWishlist:guid}")]
        public async Task<IActionResult> DeleteWishlist(Guid idWishlist)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var rows = await _service.DeleteWishlistAsync(idWishlist);
            return rows == 0 ? NotFound() : NoContent();
        }

        // WISHLIST ITEMS
        [HttpGet("wishlist-items")]
        public async Task<IActionResult> GetWishlistItems()
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            return Ok(await _service.GetWishlistItemsAllAsync());
        }

        [HttpGet("wishlist-items/{idWishlistItem:guid}")]
        public async Task<IActionResult> GetWishlistItem(Guid idWishlistItem)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var item = await _service.GetWishlistItemByIdAsync(idWishlistItem);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpPost("wishlist-items")]
        public async Task<IActionResult> CreateWishlistItem([FromBody] WishlistItem item)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var id = await _service.InsertWishlistItemAsync(item);
            item.IdWishlistItem = id;
            return CreatedAtAction(nameof(GetWishlistItem), new { idWishlistItem = id }, item);
        }

        [HttpPut("wishlist-items/{idWishlistItem:guid}")]
        public async Task<IActionResult> UpdateWishlistItem(Guid idWishlistItem, [FromBody] WishlistItem item)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            if (idWishlistItem != item.IdWishlistItem) return BadRequest();
            var rows = await _service.UpdateWishlistItemAsync(item);
            return rows == 0 ? NotFound() : NoContent();
        }

        [HttpDelete("wishlist-items/{idWishlistItem:guid}")]
        public async Task<IActionResult> DeleteWishlistItem(Guid idWishlistItem)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var rows = await _service.DeleteWishlistItemAsync(idWishlistItem);
            return rows == 0 ? NotFound() : NoContent();
        }

        // FAVORITES
        [HttpGet("favorites")]
        public async Task<IActionResult> GetFavorites()
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            return Ok(await _service.GetFavoritesAllAsync());
        }

        [HttpGet("favorites/{idFavorite:guid}")]
        public async Task<IActionResult> GetFavorite(Guid idFavorite)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var item = await _service.GetFavoriteByIdAsync(idFavorite);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpPost("favorites")]
        public async Task<IActionResult> CreateFavorite([FromBody] Favorite favorite)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var id = await _service.InsertFavoriteAsync(favorite);
            favorite.IdFavorite = id;
            return CreatedAtAction(nameof(GetFavorite), new { idFavorite = id }, favorite);
        }

        [HttpPut("favorites/{idFavorite:guid}")]
        public async Task<IActionResult> UpdateFavorite(Guid idFavorite, [FromBody] Favorite favorite)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            if (idFavorite != favorite.IdFavorite) return BadRequest();
            var rows = await _service.UpdateFavoriteAsync(favorite);
            return rows == 0 ? NotFound() : NoContent();
        }

        [HttpDelete("favorites/{idFavorite:guid}")]
        public async Task<IActionResult> DeleteFavorite(Guid idFavorite)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var rows = await _service.DeleteFavoriteAsync(idFavorite);
            return rows == 0 ? NotFound() : NoContent();
        }

        // FAVORITE ITEMS
        [HttpGet("favorite-items")]
        public async Task<IActionResult> GetFavoriteItems()
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            return Ok(await _service.GetFavoriteItemsAllAsync());
        }

        [HttpGet("favorite-items/{idFavoriteItem:guid}")]
        public async Task<IActionResult> GetFavoriteItem(Guid idFavoriteItem)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var item = await _service.GetFavoriteItemByIdAsync(idFavoriteItem);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpPost("favorite-items")]
        public async Task<IActionResult> CreateFavoriteItem([FromBody] FavoriteItem item)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var id = await _service.InsertFavoriteItemAsync(item);
            item.IdFavoriteItem = id;
            return CreatedAtAction(nameof(GetFavoriteItem), new { idFavoriteItem = id }, item);
        }

        [HttpPut("favorite-items/{idFavoriteItem:guid}")]
        public async Task<IActionResult> UpdateFavoriteItem(Guid idFavoriteItem, [FromBody] FavoriteItem item)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            if (idFavoriteItem != item.IdFavoriteItem) return BadRequest();
            var rows = await _service.UpdateFavoriteItemAsync(item);
            return rows == 0 ? NotFound() : NoContent();
        }

        [HttpDelete("favorite-items/{idFavoriteItem:guid}")]
        public async Task<IActionResult> DeleteFavoriteItem(Guid idFavoriteItem)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var rows = await _service.DeleteFavoriteItemAsync(idFavoriteItem);
            return rows == 0 ? NotFound() : NoContent();
        }
    }
}

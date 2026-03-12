CREATE TABLE IF NOT EXISTS wishlists (
  id_wishlist UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_user UUID NOT NULL REFERENCES users(id_user) ON DELETE CASCADE,
  created_at TIMESTAMP DEFAULT now(),
  UNIQUE (id_user)
);

CREATE TABLE IF NOT EXISTS wishlist_items (
  id_wishlist_item UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_wishlist UUID NOT NULL REFERENCES wishlists(id_wishlist) ON DELETE CASCADE,
  course_id UUID REFERENCES courses(id_course) ON DELETE SET NULL,
  added_at TIMESTAMP DEFAULT now()
);

CREATE TABLE IF NOT EXISTS favorites (
  id_favorite UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_user UUID NOT NULL REFERENCES users(id_user) ON DELETE CASCADE,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now(),
  UNIQUE (id_user)
);

CREATE TABLE IF NOT EXISTS favorite_items (
  id_favorite_item UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_favorite UUID NOT NULL REFERENCES favorites(id_favorite) ON DELETE CASCADE,
  id_professor UUID NOT NULL REFERENCES professors(id_professor) ON DELETE CASCADE,
  added_at TIMESTAMP DEFAULT now(),
  UNIQUE(id_favorite, id_professor)
);
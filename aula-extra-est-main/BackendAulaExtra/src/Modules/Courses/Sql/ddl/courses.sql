CREATE TABLE IF NOT EXISTS tutoring_types (
  id_tutoring_type UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) NOT NULL,
  description VARCHAR(255),
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

CREATE TABLE IF NOT EXISTS pricing_models (
  id_pricing_model UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) NOT NULL,
  description VARCHAR(255),
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

CREATE TABLE IF NOT EXISTS courses (
  id_course UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_professor UUID REFERENCES professors(id_professor),
  id_pricing_model UUID REFERENCES pricing_models(id_pricing_model),
  id_tutoring_type UUID REFERENCES tutoring_types(id_tutoring_type),
  id_disciplina UUID REFERENCES disciplinas(id_disciplina),
  id_ano_escolaridade UUID REFERENCES anos_escolaridade(id_ano_escolaridade),
  id_ciclo_estudo UUID REFERENCES ciclos_estudo(id_ciclo_estudo),
  name VARCHAR(200) NOT NULL,
  description TEXT,
  level_of_education VARCHAR(100),
  num_max_students INTEGER,
  num_min_students INTEGER,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now(),
  UNIQUE (id_professor, id_disciplina, id_ano_escolaridade, id_tutoring_type)
);

CREATE TABLE IF NOT EXISTS course_prices (
  id_course_price UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_course UUID NOT NULL REFERENCES courses(id_course) ON DELETE CASCADE,
  session_price NUMERIC(10,2),
  price_per_student NUMERIC(10,2),
  number_students INTEGER,
  active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);
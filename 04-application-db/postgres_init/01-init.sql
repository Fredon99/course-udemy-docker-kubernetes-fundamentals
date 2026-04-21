CREATE TABLE IF NOT EXISTS jokes (
    id SERIAL PRIMARY KEY,
    joke TEXT NOT NULL UNIQUE
);

INSERT INTO jokes (joke)
VALUES
    ('O que o pato falou para a pata? Vem qua.'),
    ('Voce sabe qual e o rei dos queijos? O reiqueijao.'),
    ('Qual e o animal mais antigo? A zebra, porque ela e em preto e branco.')
ON CONFLICT (joke) DO NOTHING;
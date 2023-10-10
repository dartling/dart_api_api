create extension vector with schema extensions;

-- documents to store our text data and their embeddings
create table documents (
  id serial primary key,
  title text not null,
  body text not null,
  embedding vector(1536)
);

-- function to perform similarity search on documents
create or replace function match_documents (
  query_embedding vector(1536),
  match_threshold float,
  match_count int
)
returns table (
  id bigint,
  body text,
  similarity float
)
language sql stable
as $$
  select
    documents.id,
    documents.body,
    1 - (documents.embedding <=> query_embedding) as similarity
  from documents
  where 1 - (documents.embedding <=> query_embedding) > match_threshold
  order by similarity desc
  limit match_count;
$$;

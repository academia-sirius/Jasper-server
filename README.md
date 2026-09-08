# JasperReports Server CE 8.0.0

Projeto Docker para executar JasperReports Server Community Edition 8.0.0 com PostgreSQL. A configuracao foi ajustada para deploy no Coolify atras de Caddy/reverse proxy.

## Servicos

- `jrs-server`: Tomcat 9 + JasperReports Server em HTTP interno na porta `8080`.
- `jrs-postgresql`: PostgreSQL com volume persistente `jrs_pgdata`.
- `jrs_keystore`: volume persistente para as chaves geradas pelo JasperReports.

O banco e inicializado pelo dump em `js-docker/init/jasper_backup.sql`. O Postgres so executa arquivos de `/docker-entrypoint-initdb.d` quando o volume de dados esta vazio; se voce trocar o dump depois, recrie o volume do banco ou restaure manualmente.

## Deploy no Coolify

1. Crie a aplicacao como Docker Compose apontando para este repositorio.
2. Configure o dominio no Coolify/Caddy apontando para o servico `jrs-server` na porta `8080`.
3. Defina as variaveis de ambiente:

```env
POSTGRES_PASSWORD=use-uma-senha-longa
JRS_PUBLIC_URL=https://reports.example.com/jasperserver/
```

Nao defina `POSTGRES_USER` ou `POSTGRES_DB` no Coolify para este compose. O dump
em `js-docker/init/jasper_backup.sql` foi gerado com owner `postgres` e banco
`jasperserver`; trocar esses valores faz a importacao inicial falhar.

4. Faca o deploy.
5. Acesse `https://reports.example.com/jasperserver/`.

Nao exponha o PostgreSQL para a internet. O Compose principal nao publica a porta `5432` no host.

## Caddy

Se o Caddy estiver na mesma rede Docker/Coolify, use o exemplo em `deploy/caddy/Caddyfile.example`:

```caddyfile
reports.example.com {
    reverse_proxy jrs-server:8080
}
```

Se o Caddy estiver instalado diretamente no host da VPS, suba com o override que publica somente em localhost:

```bash
docker compose -f docker-compose.yaml -f docker-compose.caddy-host.yaml up -d --build
```

Nesse caso o Caddy pode usar:

```caddyfile
reports.example.com {
    reverse_proxy 127.0.0.1:9090
}
```

## Rodar localmente

```bash
docker compose -f docker-compose.yaml -f docker-compose.caddy-host.yaml up -d --build
```

URL local:

```text
http://localhost:9090/jasperserver/
```

Logs:

```bash
docker compose logs -f jrs-server
```

Parar mantendo dados:

```bash
docker compose down
```

Apagar dados e reinicializar pelo dump:

```bash
docker compose down -v
```

Se o primeiro deploy falhar durante a inicializacao do PostgreSQL, remova o
volume `jrs_pgdata` no Coolify antes de fazer novo deploy. O Postgres so executa
o dump quando o volume esta vazio.

## Credenciais iniciais do JasperReports

As credenciais dependem do dump importado. Em instalacoes CE minimas, os usuarios padrao costumam ser:

```text
jasperadmin / jasperadmin
joeuser / joeuser
```

Troque as senhas apos o primeiro login.

## Observacoes de producao

- `POSTGRES_PASSWORD=postgres` existe apenas como default local; sobrescreva no Coolify.
- `POSTGRES_USER` e `POSTGRES_DB` ficam fixos como `postgres` e `jasperserver`
  porque o dump usa esses nomes internamente.
- `JRS_PUBLIC_URL` deve terminar com `/jasperserver/`, principalmente se usar agendamento de relatorios por email.
- JasperReports 8.0.0 e antigo. Antes de expor publicamente, mantenha Caddy com TLS, restrinja acesso quando possivel e avalie atualizacao futura do Jasper/PostgreSQL.

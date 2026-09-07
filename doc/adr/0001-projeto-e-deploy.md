# ADR 0001 - Projeto e deploy do JasperReports Server

## Status

Aceito.

## Contexto

Este repositorio empacota o JasperReports Server Community Edition 8.0.0 para
execucao em containers Docker. O objetivo e manter uma instalacao reproduzivel
do JasperReports Server com PostgreSQL, preparada para uso atras de um reverse
proxy, especialmente em ambientes como Coolify e Caddy.

O projeto inclui:

- `docker-compose.yml`: stack principal com JasperReports Server e PostgreSQL.
- `js-docker/Dockerfile`: imagem do JasperReports Server sobre Tomcat 9 e Java
  11.
- `js-docker/init/jasper_backup.sql`: dump usado na primeira inicializacao do
  banco.
- `deploy/caddy/Caddyfile.example`: exemplo de proxy reverso com Caddy.
- `docker-compose.caddy-host.yml`: override para publicar a aplicacao apenas em
  `localhost`, quando o Caddy roda direto no host da VPS.
- `.env.example`: exemplo das variaveis esperadas para deploy.

## Decisao

Manter o JasperReports Server em uma stack Docker Compose com dois servicos:

- `jrs-server`: Tomcat 9 executando JasperReports Server em HTTP interno na
  porta `8080`.
- `jrs-postgresql`: PostgreSQL 12 com volume persistente para os dados.

TLS deve ser terminado fora do container da aplicacao, preferencialmente no
Caddy ou no proxy do Coolify. O container do JasperReports recebe trafego HTTP
interno e confia nos headers `X-Forwarded-*` configurados pelo proxy.

O PostgreSQL nao deve ser exposto publicamente. No Compose principal, a porta
`5432` nao e publicada no host.

## Arquitetura

Fluxo esperado em producao:

```text
Internet
  -> Caddy/Coolify com TLS
  -> jrs-server:8080
  -> jrs-postgresql:5432
```

Persistencia:

- `jrs_pgdata`: dados do PostgreSQL.
- `jrs_keystore`: chaves geradas/usadas pelo JasperReports.

Inicializacao do banco:

- O Postgres executa os arquivos em `js-docker/init` somente quando o volume de
  dados esta vazio.
- Se `js-docker/init/jasper_backup.sql` for alterado depois do primeiro deploy,
  sera necessario recriar o volume do banco ou restaurar o dump manualmente.

## Variaveis de ambiente

Variaveis minimas para producao:

```env
POSTGRES_USER=postgres
POSTGRES_PASSWORD=use-uma-senha-longa
POSTGRES_DB=jasperserver
JRS_PUBLIC_URL=https://reports.example.com/jasperserver/
```

Observacoes:

- `POSTGRES_PASSWORD=postgres` existe apenas como padrao local. Em producao,
  sempre sobrescrever com uma senha forte.
- `JRS_PUBLIC_URL` deve terminar com `/jasperserver/`.
- Quando o Caddy roda no host, `JRS_HTTP_BIND` e `JRS_HTTP_PORT` podem ser
  usados pelo override `docker-compose.caddy-host.yml`.

## Deploy no Coolify

1. Criar uma aplicacao do tipo Docker Compose apontando para este repositorio.
2. Configurar as variaveis de ambiente usando `.env.example` como referencia.
3. Configurar o dominio no Coolify para apontar para o servico `jrs-server` na
   porta `8080`.
4. Fazer o deploy pelo Coolify.
5. Acessar a aplicacao em:

```text
https://reports.example.com/jasperserver/
```

Validacoes apos deploy:

```bash
docker compose ps
docker compose logs -f jrs-server
docker compose logs -f jrs-postgresql
```

O healthcheck do `jrs-server` valida a URL interna:

```text
http://localhost:8080/jasperserver/login.html
```

## Deploy com Caddy no host da VPS

Quando o Caddy nao esta na mesma rede Docker da aplicacao, publicar o
JasperReports apenas em `localhost`:

```bash
docker compose -f docker-compose.yml -f docker-compose.caddy-host.yml up -d --build
```

Exemplo de Caddy:

```caddyfile
reports.example.com {
    reverse_proxy 127.0.0.1:9090
}
```

Nesse modo, o JasperReports fica acessivel localmente em:

```text
http://localhost:9090/jasperserver/
```

## Execucao local

Subir a stack:

```bash
docker compose -f docker-compose.yml -f docker-compose.caddy-host.yml up -d --build
```

Acompanhar logs:

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
docker compose -f docker-compose.yml -f docker-compose.caddy-host.yml up -d --build
```

## Backup e restore

Backup recomendado do banco:

```bash
docker compose exec jrs-postgresql pg_dump -U "$POSTGRES_USER" "$POSTGRES_DB" > jasper_backup.sql
```

Restore em um banco ja existente:

```bash
docker compose exec -T jrs-postgresql psql -U "$POSTGRES_USER" "$POSTGRES_DB" < jasper_backup.sql
```

Antes de restaurar em producao, parar agendamentos e garantir uma copia do
volume `jrs_pgdata`.

## Operacao

Comandos uteis:

```bash
docker compose ps
docker compose logs -f jrs-server
docker compose logs -f jrs-postgresql
docker compose restart jrs-server
```

Credenciais iniciais dependem do dump importado. Em instalacoes CE minimas,
costumam existir:

```text
jasperadmin / jasperadmin
joeuser / joeuser
```

As senhas devem ser trocadas no primeiro acesso.

## Seguranca

- Nao publicar o PostgreSQL na internet.
- Usar TLS no Caddy/Coolify.
- Definir uma senha forte para `POSTGRES_PASSWORD`.
- Trocar as credenciais padrao do JasperReports.
- Restringir acesso por rede, VPN, allowlist ou autenticacao adicional quando
  possivel.
- Considerar que JasperReports Server CE 8.0.0 e uma versao antiga; antes de
  expor publicamente, avaliar atualizacao, hardening e monitoramento.

## Consequencias

Beneficios:

- Ambiente reproduzivel com Docker Compose.
- Deploy simples no Coolify.
- Banco e keystore persistentes por volume.
- TLS e roteamento ficam centralizados no proxy.

Trade-offs:

- O primeiro start pode demorar porque o JasperReports executa configuracoes via
  buildomatic.
- Alteracoes no dump inicial nao afetam bancos ja inicializados.
- A operacao depende de manter backups consistentes do PostgreSQL e dos volumes.
- Atualizacoes de JasperReports, Java, Tomcat ou PostgreSQL devem ser testadas em
  ambiente separado antes de producao.

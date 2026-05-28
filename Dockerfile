# syntax=docker/dockerfile:1

# =========================
# Этап 1. Сборка приложения
# =========================
FROM golang:1.22-alpine AS builder

WORKDIR /go/src/github.com/Securing-DevOps/invoicer-chapter2

# gcc и musl-dev нужны только для сборки Go-приложения с sqlite
RUN apk add --no-cache gcc musl-dev

COPY . .

# Проект старый, поэтому собираем его без Go modules, через vendor
RUN CGO_ENABLED=1 GO111MODULE=off go build \
    -tags "sqlite_omit_load_extension" \
    -ldflags '-linkmode external -extldflags "-static"' \
    -o /out/invoicer .


# =========================
# Этап 2. Финальный образ
# =========================
FROM alpine:3.20

WORKDIR /app

# Создаём непривилегированного пользователя
RUN addgroup -S -g 10001 appgroup && \
    adduser -S -D -H -u 10001 -G appgroup appuser && \
    mkdir -p /app/statics && \
    chown -R appuser:appgroup /app

# Копируем только готовый бинарник и статические файлы
COPY --from=builder --chown=appuser:appgroup /out/invoicer /app/invoicer
COPY --chown=appuser:appgroup statics /app/statics

# Запускаем приложение от непривилегированного пользователя
USER appuser

# Открыт только нужный порт
EXPOSE 8080

ENTRYPOINT ["/app/invoicer"]
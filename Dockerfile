FROM golang:1.19.1-alpine as builder
ARG GOPROXY=https://goproxy.cn,direct

COPY . /app
WORKDIR /app
RUN go env -w GOPROXY=${GOPROXY} \
    && CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o bot main.go


FROM alpine:3
RUN echo "export LANG=en_US.UTF-8" > /etc/profile.d/locale.sh \
    && sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk update && apk --no-cache add tzdata \
    && cp -rf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

RUN mkdir -p /usr/local/app
COPY --from=builder /app/bot /usr/local/app

EXPOSE 8080
WORKDIR /usr/local/app

ENTRYPOINT [ "./bot" ]
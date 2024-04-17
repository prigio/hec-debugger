# Stage 1: Build the Go application
FROM golang:1.21 AS builder

# Set the Current Working Directory inside the container
WORKDIR /workdir

# Copy go mod and sum files
COPY go.mod go.sum main.go ./

# Download all dependencies. Dependencies will be cached if the go.mod and go.sum files are not changed
RUN go mod download

# Copy the source from the current directory to the Working Directory inside the container
COPY . .

# Build the Go app
#RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o myapp .
# https://www.digitalocean.com/community/tutorials/building-go-applications-for-different-operating-systems-and-architectures
#RUN GOOS=linux GOARCH=arm64 go build -o ./hec-debugger
#RUN GOOS=linux GOARCH=amd64 go build -o ./hec-debugger
RUN go build -o ./hec-debugger


# Stage 2: Use a scratch image
FROM alpine:latest
# Copy the Pre-built binary file from the previous stage
COPY --from=builder /workdir/hec-debugger /hec-debugger
EXPOSE 8765
WORKDIR /
# Command to run the executable
ENTRYPOINT ["/hec-debugger"]
CMD ["-listen", "127.0.0.1:8765", "-pprint", "-print-records", "3"]

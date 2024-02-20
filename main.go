package main

/*
This is a simple web server which:

- Listens for any HTTP method on the specified interface
- Logs to STDOUT:
	- the URL requested,
	- the provided "Authorization" header,
	- the count of records provided within the request body
	- the first X records of the request body, if any
- Replies an HTTP 200 to the caller.
- Records are interpreted as JSON objects, depending on the ending of the url being used.
	- .json: an array of objects
	- .ndjson: newline separatetd objects
	- .hec: objects one after another, without newlines in between

From the point of view of the caller, you can compare this to sending HTTP data to /dev/null.

Why use this? to inspect/debug data being sent to a Splunk HEC endpoint
*/
import (
	"bytes"
	"compress/gzip"
	"encoding/json"
	"flag"
	"fmt"
	"io"
	"log"
	"net/http"
	"strconv"
	"strings"

	"github.com/TylerBrock/colorjson"
	"github.com/gin-gonic/gin"
)

func main() {
	// Define command line flags for IP address and port
	listenPtr := flag.String("listen", "127.0.0.1:8765", "IP address and port to listen on")
	printRecordsPtr := flag.Int64("print-records", 3, "Number of received records to print-out to STDOUT. Set to 0 to print all")
	prettyprintPtr := flag.Bool("pprint", false, "Set to true to pretty-print json-encoded incoming data")
	flag.Parse()

	gin.SetMode(gin.ReleaseMode)

	// Initialize the Gin router
	r := gin.Default()

	// Define a route that handles ALL incoming HTTP requests
	r.Any("/*any", func(c *gin.Context) {
		objkey := c.Param("any")
		var lines []string
		var i int64 = 0
		if strings.Contains(c.GetHeader("Content-Encoding"), "gzip") {
			gzipReader, err := gzip.NewReader(c.Request.Body)
			if err != nil {
				c.JSON(http.StatusBadRequest, gin.H{"error": "Error decoding gzip"})
				return
			}
			defer gzipReader.Close()
			decompressedBody, err := io.ReadAll(gzipReader)
			if err != nil {
				c.JSON(http.StatusBadRequest, gin.H{"error": "Error reading decompressed body"})
				return
			}
			c.Request.Body = io.NopCloser(bytes.NewBuffer(decompressedBody))
		}
		var l []byte

		colorJsonFormatter := colorjson.NewFormatter()
		colorJsonFormatter.Indent = 2
		if strings.HasSuffix(objkey, ".json") {
			// expects the input to be a json-encoded array of objects
			var obj []map[string]interface{}
			scanner := json.NewDecoder(c.Request.Body)
			defer c.Request.Body.Close()
			for scanner.More() {
				if err := scanner.Decode(&obj); err != nil {
					fmt.Printf("Error decoding JSON: %s\n", err)
					break
				}
				if *printRecordsPtr > 0 && i < *printRecordsPtr {
					var j int = 0
					for i < *printRecordsPtr && j < len(obj) {
						if *prettyprintPtr {
							//l, _ = json.MarshalIndent(obj[j], "\t", "  ")
							l, _ = colorJsonFormatter.Marshal(obj[j])
						} else {
							l, _ = json.Marshal(obj[j])
						}
						lines = append(lines, string(l))
						j += 1
						i += 1
					}
				} else {
					i += 1
				}
			}
		} else {
			// expects the input to be a series of JSON objects either serialized one after another (as splunk's HEC protocol) or with new-lines inbetween (ndjson)
			// if strings.HasSuffix(objkey, ".ndjson") || strings.HasSuffix(objkey, ".hec")
			var obj map[string]interface{}
			scanner := json.NewDecoder(c.Request.Body)
			defer c.Request.Body.Close()
			for scanner.More() {
				if err := scanner.Decode(&obj); err != nil {
					log.Printf("Error decoding JSON: %s\n", err)
					break
				}
				if *printRecordsPtr > 0 && i < *printRecordsPtr {
					if *prettyprintPtr {
						l, _ = colorJsonFormatter.Marshal(obj)
						//l, _ = json.MarshalIndent(obj, "\t", "  ")
					} else {
						l, _ = json.Marshal(obj)
					}
					lines = append(lines, string(l))
				}
				i += 1
			}
		}
		log.Printf(`- %s %s
  Authorization: %s
  Tot records: %d
  First records received:
%s
`, c.Request.Method, objkey, c.Request.Header.Get("Authorization"), i, strings.Join(lines, "\n"))
		// Respond with status code 200
		c.Status(http.StatusOK)
	})

	// Start the server
	var cntRecords string = "all"
	if *printRecordsPtr > 0 {
		cntRecords = strconv.FormatInt(*printRecordsPtr, 10)
	}
	log.Printf("Starting hec-debugger: listening on '%s', printing-out %s received records.\n", *listenPtr, cntRecords)
	err := r.Run(*listenPtr)
	if err != nil {
		log.Println("Failed to start server: " + err.Error())
	}
	log.Println("Exited.")
}

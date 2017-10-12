package main

import (
	"net/http"
	"fmt"
	"io/ioutil"
	"encoding/json"
	"strings"
	"strconv"
	"os"
	"time"
)

type MasterSnapshot struct {
	ActiveSlaveNum float32	`json:"master/slaves_active"`
	ConnectedSlaveNum float32	`json:"master/slaves_connected"`
	DisconnectedSlaveNum float32	`json:"master/slaves_disconnected"`
	InactiveSlaveNum float32	`json:"master/slaves_inactive"`
}

var DBName string = "mydcos"
var InfluxdbUrl string = "http://influxdb.dev.cwc.marathon.mesos:8086"
type MetricData struct {
	meas string
	tags []string
	value	float32
}

func send(s MasterSnapshot){
	dbname := os.Getenv("DB_NAME")
	if dbname == ""{
		dbname = DBName
	}

	influxdbUrl := os.Getenv("INFLUXDB_URL")
	if influxdbUrl == ""{
		influxdbUrl = InfluxdbUrl
	}

	data := strings.Join([]string{"slave,type=disconnected","value="+strconv.Itoa(int(s.DisconnectedSlaveNum)),
		"\n slave,type=inactive","value="+strconv.Itoa(int(s.InactiveSlaveNum)),
		"\n slave,type=active","value="+strconv.Itoa(int(s.ActiveSlaveNum)),
		"\n slave,type=connected","value="+strconv.Itoa(int(s.ConnectedSlaveNum))}," ")
	resp,err := http.Post(influxdbUrl+"/write?db="+dbname+"&rp=autogen","binary",strings.NewReader(data))

	if err != nil{
		fmt.Println(err.Error())
	}
	defer resp.Body.Close()
	respData,_ := ioutil.ReadAll(resp.Body)
	fmt.Println(string(respData))
	fmt.Println("Send: ",data,", Status: ",resp.Status)
}

func monitor(){
	resp,err := http.Get("http://leader.mesos:5050/metrics/snapshot")
	if err != nil{
		fmt.Println(err.Error())
	}
	defer resp.Body.Close()
	data,_ := ioutil.ReadAll(resp.Body)
	var masterSnapshot MasterSnapshot
	json.Unmarshal(data,&masterSnapshot)
	send(masterSnapshot)

}

func main(){
	for{
		monitor()
		time.Sleep(60*time.Second)
	}

}

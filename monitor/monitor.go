package main

import (
	"net/http"
	"fmt"
	"io/ioutil"
	"encoding/json"
	"strings"
	"os"
	"time"
)

type MasterSnapshot struct {
	ActiveSlaveNum float32	`json:"master/slaves_active"`
	ConnectedSlaveNum float32	`json:"master/slaves_connected"`
	DisconnectedSlaveNum float32	`json:"master/slaves_disconnected"`
	InactiveSlaveNum float32	`json:"master/slaves_inactive"`
}

type Slave struct {
	Hostname string `json:"hostname"`
	Active	bool	`json:"active"`
}

type State struct {
	ActivatedSalves float32 `json:"activated_slaves"`
	DeadActivatedSlaves float32 `json:"deactivated_slaves"`
	UnreachableSlaves float32 `json:"unreachable_slaves"`
	Slaves []Slave `json:"slaves"`
}

var DBName string = "dcos"
var InfluxdbUrl string = "http://influxdb.dev.cwc.marathon.mesos:8086"

var StateMeasureMent = "state"
var SlavesMeasureMent = "slave"

type MetricData struct {
	meas string
	tags []string
	value	float32
}

func send( data string){
	dbname := os.Getenv("DB_NAME")
	if dbname == ""{
		dbname = DBName
	}

	influxdbUrl := os.Getenv("INFLUXDB_URL")
	if influxdbUrl == ""{
		influxdbUrl = InfluxdbUrl
	}
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

	resp,err := http.Get("http://leader.mesos:5050/state")
	if err != nil{
		fmt.Println(err.Error())
	}
	defer resp.Body.Close()
	data,_ := ioutil.ReadAll(resp.Body)
	var state State
	json.Unmarshal(data,&state)
	fmt.Println(state)
	sendStr := strings.Join([]string{
		fmt.Sprintf("%s,type=activated value=%d",StateMeasureMent,int(state.ActivatedSalves)),
		fmt.Sprintf("\n %s,type=deadactivated value=%d",StateMeasureMent,int(state.DeadActivatedSlaves)),
		fmt.Sprintf("\n %s,type=unreachable value=%d",StateMeasureMent,int(state.UnreachableSlaves))}," ")

	for _,slave :=range state.Slaves{
		sendStr = sendStr + strings.Join([]string{
			fmt.Sprintf("\n %s,hostname=%s value=%t",SlavesMeasureMent,slave.Hostname,slave.Active),
		}, " ")
	}
	send(sendStr)
}

func main(){
	for{
		monitor()
		time.Sleep(60*time.Second)
	}

}

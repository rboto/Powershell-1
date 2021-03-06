get-UDDashboard | Stop-UDDashboard

$servername = $env:computername

$date = Get-Date -format "dd-MMM-yyyy HH:mm"

$Dashboard_title = "| isPowerShell UDashboard | Server: $servername | Date: $date |"

# Last System Error Event
$error_system = try{Get-EventLog -LogName System -EntryType Information  -ErrorAction stop | Sort-Object Time | Select-Object -Last 3}catch{$error_system_message = "No application Error";$sys_null = $true}


# Last Application Error Event
$error_application = try{Get-EventLog -LogName application -EntryType information -ErrorAction stop | Sort-Object Time | Select-Object -Last 3}catch{$error_application_message = "No application Error";$app_null = $true}



$page = @( 


# Page Event Log
            New-UDPage -Name "Event" -Content {

            New-UDHeading -Text "Event Dashboard Viewer" -Size 5

            New-UDTable -Title "System Event Log" -Headers @("Time", "Source", "Message") -FontColor "black" -Endpoint {
                                        $error_system | Out-UDTableData -Property @("Timegenerated", "Source", "Message")
                                      }
            New-UDTable -Title "Application Event Log" -Headers @("Time", "Source", "Message") -FontColor "black" -Endpoint {
                                        $error_application | Out-UDTableData -Property @("Timegenerated", "Source", "Message")
                                        }
                                        }  

# Page Processor & Memory
            New-UDPage -Name "Memory & Processor" -Content {

    New-UDRow {
        New-UDColumn -Size 12 {
            New-UDRow {
                New-UDColumn -Size 6 {
                            New-UDMonitor -Title "Memory(%)" -Type Line -Width "100%" -ChartBackgroundColor '#ff5050' -ChartBorderColor '#cc0000' -Endpoint {
                                                $memory = get-counter "\Memory\% Committed Bytes In Use"| Select-Object -ExpandProperty CounterSamples | Select-object -ExpandProperty CookedValue
                                                $memory | Out-UDMonitorData
                                                                                   } -DataPointHistory 20 -RefreshInterval 5
                                      }

                New-UDColumn -Size 6 {
                                    
                             New-UDMonitor -Title "Processor(%)" -Type Line -Width "100%" -ChartBackgroundColor '#3399ff' -ChartBorderColor '#0000ff' -Endpoint {
                                                $processor = get-counter "\processor(_total)\% processor time"| Select-Object -ExpandProperty CounterSamples | Select-object -ExpandProperty CookedValue
                                                $processor | Out-UDMonitorData
                                                                                   } -DataPointHistory 20 -RefreshInterval 1


                }
            }
        }


 
        }




          }

# Page Hard disk / Storage

            New-UDPage -Name "Storage" -Content {

    New-UDRow {
        New-UDColumn -Size 12 {
            New-UDRow {
                New-UDColumn -Size 6 {
                            New-UDMonitor -Title "Disk Access Time(%)" -Type Line -Width "100%" -ChartBackgroundColor '#ff5050' -ChartBorderColor '#cc0000' -Endpoint {
                                                $diskusage = get-counter "\\bashboard-srv\physicaldisk(_total)\% disk time"| Select-Object -ExpandProperty CounterSamples | Select-object -ExpandProperty CookedValue
                                                $diskusage | Out-UDMonitorData
                                                                                   } -DataPointHistory 20 -RefreshInterval 5
                                      }

                New-UDColumn -Size 6 {
                                    New-UdChart -Title "Storage Space" -Type Bar -AutoRefresh -Endpoint {
                                    [int]$freespace = get-counter -counter "\logicaldisk(_total)\% free space" | Select-Object -ExpandProperty CounterSamples | Select-object -ExpandProperty CookedValue
                                         $freespace = [math]::Round($freespace)

                                         $occupedspace = 100 - $freespace

                                         $object = [PSCustomObject]@{Name = "Storage Total(%)";FreeSpace = $freespace;OccupedSpace = $occupedspace}
                                
                                         $object | Out-UDChartData -LabelProperty "Name" -Dataset @(
                                                                    New-UdChartDataset -DataProperty "OccupedSpace" -Label "Occuped Space" -BackgroundColor "#80962F23" -HoverBackgroundColor "#80962F23"
                                                                    New-UdChartDataset -DataProperty "FreeSpace" -Label "Free Space" -BackgroundColor "#8014558C" -HoverBackgroundColor "#8014558C"
                                                                                              )
                                                }
                                        }
                                }
                                }
        }


 
     }

         

# Page CNN news
New-UDPage -Name "News" -Content {


                           $www = "http://rss.cnn.com/rss/cnn_topstories.rss"
                    [array]$cnn = (Invoke-RestMethod -Uri $www).description
                      [int]$news_count = $cnn.count



                    [array]$news_list  = foreach($text in $cnn){
                                                       
                                            $pos = $text.IndexOf("<div")
                                            $news = $text.Substring(0, $pos)
                                            $news
                                                                }

0..$news_count | foreach{

     $num = $_
     [string]$text = $news_list[$num]
    new-udcard -Title "CNN NEWS" -Content {$text}
                                             
                        }
                                            


    

                    
                                                           
                         
                                                                     
                                                                     

}
                
                
                
                )



$Dashboard = New-UDDashboard -Pages $page




Start-UDDashboard -Dashboard $Dashboard -Port 10001







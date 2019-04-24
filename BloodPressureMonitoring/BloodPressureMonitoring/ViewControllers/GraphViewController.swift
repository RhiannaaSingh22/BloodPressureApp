//
//  GraphViewController.swift
//  BloodPressureMonitoring
//
//  Created by Rhiannaa Singh on 20/04/2019.
//  Copyright © 2019 Rhiannaa Singh. All rights reserved.
//
/*
 References:
    Schütz, I. (2019). SwiftCharts. [online] GitHub. Available at: https://github.com/i-schuetz/SwiftCharts 
 */

import UIKit
import SwiftCharts
import CoreData

class GraphViewController: UIViewController {

    @IBOutlet weak var highestVal: UILabel!
    @IBOutlet weak var highP: UILabel!
    @IBOutlet weak var avgVal: UILabel!
    
    var bpGraph:LineChart!
    
    @IBOutlet weak var graphViewArea: UIView!
    
    var resultsControllerR: NSFetchedResultsController<Reading>!
    let coreDataStackR = CoreDataStack()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //REQUEST
        let requestR: NSFetchRequest<Reading> = Reading.fetchRequest()
        let sortDescriptors = NSSortDescriptor(key: "date", ascending: true)
        
        //INITIALISE
        requestR.sortDescriptors = [sortDescriptors]
        resultsControllerR = NSFetchedResultsController(
            fetchRequest: requestR,
            managedObjectContext: coreDataStackR.managedContextR,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        //FETCH
        do{
            try resultsControllerR.performFetch()
        } catch{
            print("perform fetch error:\(error)")
        }
        
        createGraph()
        getHighest()
        getHighPercentage()
        getAvg()
        // Do any additional setup after loading the view.
    }
    
    func createGraph(){
        
        let frame = CGRect(x: 0, y: 150, width: self.view.frame.width-10, height: 350)
        
        let readings = resultsControllerR.fetchedObjects!

        var sys = [(Double,Double)]()
        var dia = [(Double,Double)]()
        
        var max = 15
        if readings.count < max{
            max = readings.count
        }
        
        let chartConfig = ChartConfigXY(
            xAxisConfig: ChartAxisConfig(from: 1, to: Double(max), by: 1),
            yAxisConfig: ChartAxisConfig(from: 0, to: 200, by: 10)
        )
        
        var i = max
        
        for reading in readings{
            sys.append((Double(i),Double(reading.sysVal!)!))
            dia.append((Double(i),Double(reading.diaVal!)!))
            i = i - 1
            if i < 1{
                break
            }
        }
        
        let graph = LineChart(
            frame: frame,
            chartConfig: chartConfig,
            xTitle: "Recent Readings",
            yTitle: "Pressure /mmHg",
            lines: [
                (chartPoints: sys, color: UIColor.blue),
                (chartPoints: dia, color: UIColor.green)
            ]
        )
        
        self.view.addSubview(graph.view)
        self.bpGraph = graph
        
    }
    
    func getHighest() {
        let readings = resultsControllerR.fetchedObjects!
        var highSys = 0
        var highDia = 0
        var max = 15
        let count = resultsControllerR.fetchedObjects!.count
        var i = 1
        
        if count <= max{
            max = readings.count
        }
        
        for reading in readings{
            if i <= max{
                if Int(reading.sysVal!)! > highSys{
                    highSys = Int(reading.sysVal!)!
                    highDia = Int(reading.diaVal!)!
                } else if Int(reading.sysVal!)! == highSys{
                    if Int(reading.diaVal!)! > highDia{
                        highDia  = Int(reading.diaVal!)!
                    }
                }
                i = i + 1
            }
        }
        let highestR = String(highSys) + "/" + String(highDia)
        highestVal.text = highestR
    }
    
    func getHighPercentage(){
        let readings = resultsControllerR.fetchedObjects!
    
        var max = 1000
        let count = resultsControllerR.fetchedObjects!.count
        var i = 1
        var cHigh = 1
        
        
        if count <= max{
            max = readings.count
        }
        
        for reading in readings{
            if i <= max{
                if reading.category == "high"{
                    cHigh = cHigh+1
                }
                i = i + 1
            }
        }
        
        let p = Int((Double(cHigh)/Double(max))*100)
        highP.text = String(p) + "%"
    }
    
    func getAvg() {
        let readings = resultsControllerR.fetchedObjects!
        
        var max = 1000
        let count = resultsControllerR.fetchedObjects!.count
        var i = 1
        var totalSys = 0
        var totalDia = 0
        
        if count <= max{
            max = readings.count
        }
        
        for reading in readings{
            if i <= max{
                totalSys = totalSys + Int(reading.sysVal!)!
                totalDia = totalDia + Int(reading.diaVal!)!
                i = i + 1
            }
        }
        
        let sysAvg = totalSys/max
        let diaAvg = totalDia/max
        
        let avg = String(sysAvg)+"/"+String(diaAvg)
        avgVal.text = avg
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

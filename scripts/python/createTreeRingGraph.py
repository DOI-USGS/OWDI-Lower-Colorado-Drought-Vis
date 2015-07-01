from xml.etree import ElementTree
from xml.dom import minidom
from xml.etree.ElementTree import Element, SubElement, Comment
import csv
import os
def main():
    svg = Element('svg')
    svg.set('xmlns', 'http://www.w3.org/2000/svg')
    svg.set('xmlns:xlink', 'http://www.w3.org/1999/xlink')
    svg.set('preserveAspectRatio', 'xMinYMin meet')
    drawLine(svg,30,15,30,347,2,'black')
    drawLine(svg,30,347,530,347,2,'black')

    drawLine(svg,25,347,35,347,2,'black')
    drawLine(svg,25,314,35,314,2,'black')
    drawLine(svg,25,281,35,281,2,'black')
    drawLine(svg,25,248,35,248,2,'black')
    drawLine(svg,25,215,35,215,2,'black')
    drawLine(svg,25,182,35,182,2,'black')
    drawLine(svg,25,149,35,149,2,'black')
    drawLine(svg,25,116,35,116,2,'black')
    drawLine(svg,25,83,35,83,2,'black')
    drawLine(svg,25,50,35,50,2,'black')
    drawLine(svg,25,15,35,15,2,'black')

    drawLine(svg,30,342,30,352,2,'black')
    drawLine(svg,130,342,130,352,2,'black')
    drawLine(svg,230,342,230,352,2,'black')
    drawLine(svg,330,342,330,352,2,'black')
    drawLine(svg,430,342,430,352,2,'black')
    drawLine(svg,530,342,530,352,2,'black')

    drawText(svg,0,22,'125')
    drawText(svg,0,57,'120')
    drawText(svg,0,90,'115')
    drawText(svg,0,123,'110')
    drawText(svg,0,156,'105')
    drawText(svg,0,189,'100')
    drawText(svg,5,224,'95')
    drawText(svg,5,257,'90')
    drawText(svg,5,290,'85')
    drawText(svg,5,323,'80')
    drawText(svg,5,356,'75')

    drawText(svg,18,367,'762')
    drawText(svg,118,367,'1012')
    drawText(svg,218,367,'1262')
    drawText(svg,318,367,'1512')
    drawText(svg,418,367,'1762')
    drawText(svg,518,367,'2012')

    drawCSV(getScriptLoc() + '/../../src_data/treeringFlow15yrProcessed.csv', svg)

    outsvg = open(getScriptLoc() + '/../../public_html/img/treering.svg','w+')
    outsvg.truncate()
    outsvg.write(prettify(svg))
    outsvg.close()
def prettify(elem):
    rough_string = ElementTree.tostring(elem, 'utf-8')
    reparsed = minidom.parseString(rough_string)
    return reparsed.toprettyxml(indent="  ")
def drawLine(ele, x1, y1, x2, y2, width, color):
    line = SubElement(ele, 'line')
    line.set('x1', str(x1))
    line.set('y1', str(y1))
    line.set('x2', str(x2))
    line.set('y2', str(y2))
    line.set('stroke', color)
    line.set('stroke-width', str(width))
    return line
def drawText(ele, x, y, tex):
    text = SubElement(ele, 'text')
    text.set('x', str(x))
    text.set('y', str(y))
    text.set('fill', 'black')
    text.text=tex
    return text
def drawGraphLine(ele,year1,perc1,year2,perc2,grey1,grey2):
    year1 = float(year1)
    year2 = float(year2)
    perc1 = float(perc1)
    perc2 = float(perc2)
    year1 = ((year1 - 762) * .4) + 30
    year2 = ((year2 - 762) * .4) + 30
    perc1 = 100 + (100-perc1)
    perc2 = 100 + (100-perc2)
    perc1 = ((perc1-75) * 6.64) + 15
    perc2 = ((perc2-75) * 6.64) + 15
    return drawLine(ele, year1, perc1, year2, perc2, 1, 'blue')
def drawCSV(floc, ele):
    with open(floc, 'rb') as csvfile:
        doc = csv.reader(csvfile, delimiter=',', quotechar='|')
        i = 0
        x = 0
        year = []
        perc = []
        grey = []
        for row in doc:
            if(i != 0 and row[1] != 'NA'):
                year.append(row[0])
                perc.append(row[1])
                grey.append(row[2])
                x+= 1
            i+= 1
        for itn in range(0, len(year)-1):
            gl = drawGraphLine(ele, year[itn], perc[itn], year[itn+1], perc[itn+1], grey[itn], grey[itn+1])
            animation = SubElement(gl, 'animate')
            animation.set('attributeName', 'visibility')
            animation.set('from', 'hidden')
            animation.set('to', 'visible')
            animation.set('dur', str(itn*.01))
def getScriptLoc():
    return os.getcwd().replace('\\','/')
main()

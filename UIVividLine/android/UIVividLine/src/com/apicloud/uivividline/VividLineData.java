package com.apicloud.uivividline;

import android.graphics.Bitmap;

public class VividLineData {
	private String mark;
	private double value;
	private Bitmap icon;
	
	public VividLineData(String mark, double value, Bitmap icon) {
		this.mark = mark;
		this.value = value;
		this.icon = icon;
	}

	public String getMark() {
		return mark;
	}

	public void setMark(String mark) {
		this.mark = mark;
	}

	public double getValue() {
		return value;
	}

	public void setValue(double value) {
		this.value = value;
	}

	public Bitmap getIcon() {
		return icon;
	}

	public void setIcon(Bitmap icon) {
		this.icon = icon;
	}
}

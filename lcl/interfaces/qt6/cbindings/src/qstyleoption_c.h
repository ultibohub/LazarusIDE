//******************************************************************************
//  Copyright (c) 2005-2022 by Jan Van hijfte, Željan Rikalo
//
//  See the included file COPYING.TXT for details about the copyright.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
//******************************************************************************


#ifndef QSTYLEOPTION_C_H
#define QSTYLEOPTION_C_H

#include <QtWidgets>
#include "pascalbind.h"

C_EXPORT int QStyleOption_version(QStyleOptionH handle);
C_EXPORT void QStyleOption_setVersion(QStyleOptionH handle, int version);
C_EXPORT int QStyleOption_type(QStyleOptionH handle);
C_EXPORT void QStyleOption_setType(QStyleOptionH handle, int type);
C_EXPORT unsigned int QStyleOption_state(QStyleOptionH handle);
C_EXPORT void QStyleOption_setState(QStyleOptionH handle, unsigned int state);
C_EXPORT Qt::LayoutDirection QStyleOption_direction(QStyleOptionH handle);
C_EXPORT void QStyleOption_setDirection(QStyleOptionH handle, Qt::LayoutDirection direction);
C_EXPORT void QStyleOption_rect(QStyleOptionH handle, PRect retval);
C_EXPORT void QStyleOption_setRect(QStyleOptionH handle, PRect rect);
C_EXPORT void QStyleOption_fontMetrics(QStyleOptionH handle, QFontMetricsH retval);
C_EXPORT void QStyleOption_setFontMetrics(QStyleOptionH handle, QFontMetricsH fontMetrics);
C_EXPORT void QStyleOption_palette(QStyleOptionH handle, QPaletteH retval);
C_EXPORT void QStyleOption_setPalette(QStyleOptionH handle, QPaletteH palette);
C_EXPORT QObjectH QStyleOption_styleObject(QStyleOptionH handle);
C_EXPORT void QStyleOption_setStyleObject(QStyleOptionH handle, QObjectH styleObject);
C_EXPORT QStyleOptionH QStyleOption_Create(int version, int type);
C_EXPORT void QStyleOption_Destroy(QStyleOptionH handle);
C_EXPORT QStyleOptionH QStyleOption_Create2(const QStyleOptionH other);
C_EXPORT void QStyleOption_initFrom(QStyleOptionH handle, const QWidgetH w);
C_EXPORT void QStyleOptionFocusRect_backgroundColor(QStyleOptionFocusRectH handle, PQColor retval);
C_EXPORT void QStyleOptionFocusRect_setBackgroundColor(QStyleOptionFocusRectH handle, PQColor backgroundColor);
C_EXPORT QStyleOptionFocusRectH QStyleOptionFocusRect_Create();
C_EXPORT void QStyleOptionFocusRect_Destroy(QStyleOptionFocusRectH handle);
C_EXPORT QStyleOptionFocusRectH QStyleOptionFocusRect_Create2(const QStyleOptionFocusRectH other);
C_EXPORT int QStyleOptionFrame_lineWidth(QStyleOptionFrameH handle);
C_EXPORT void QStyleOptionFrame_setLineWidth(QStyleOptionFrameH handle, int lineWidth);
C_EXPORT int QStyleOptionFrame_midLineWidth(QStyleOptionFrameH handle);
C_EXPORT void QStyleOptionFrame_setMidLineWidth(QStyleOptionFrameH handle, int midLineWidth);
C_EXPORT QStyleOptionFrameH QStyleOptionFrame_Create();
C_EXPORT void QStyleOptionFrame_Destroy(QStyleOptionFrameH handle);
C_EXPORT QStyleOptionFrameH QStyleOptionFrame_Create2(const QStyleOptionFrameH other);
C_EXPORT int QStyleOptionTabWidgetFrame_lineWidth(QStyleOptionTabWidgetFrameH handle);
C_EXPORT void QStyleOptionTabWidgetFrame_setLineWidth(QStyleOptionTabWidgetFrameH handle, int lineWidth);
C_EXPORT int QStyleOptionTabWidgetFrame_midLineWidth(QStyleOptionTabWidgetFrameH handle);
C_EXPORT void QStyleOptionTabWidgetFrame_setMidLineWidth(QStyleOptionTabWidgetFrameH handle, int midLineWidth);
C_EXPORT QTabBar::Shape QStyleOptionTabWidgetFrame_shape(QStyleOptionTabWidgetFrameH handle);
C_EXPORT void QStyleOptionTabWidgetFrame_setShape(QStyleOptionTabWidgetFrameH handle, QTabBar::Shape shape);
C_EXPORT void QStyleOptionTabWidgetFrame_tabBarSize(QStyleOptionTabWidgetFrameH handle, PSize retval);
C_EXPORT void QStyleOptionTabWidgetFrame_setTabBarSize(QStyleOptionTabWidgetFrameH handle, PSize tabBarSize);
C_EXPORT void QStyleOptionTabWidgetFrame_rightCornerWidgetSize(QStyleOptionTabWidgetFrameH handle, PSize retval);
C_EXPORT void QStyleOptionTabWidgetFrame_setRightCornerWidgetSize(QStyleOptionTabWidgetFrameH handle, PSize rightCornerWidgetSize);
C_EXPORT void QStyleOptionTabWidgetFrame_leftCornerWidgetSize(QStyleOptionTabWidgetFrameH handle, PSize retval);
C_EXPORT void QStyleOptionTabWidgetFrame_setLeftCornerWidgetSize(QStyleOptionTabWidgetFrameH handle, PSize leftCornerWidgetSize);
C_EXPORT void QStyleOptionTabWidgetFrame_tabBarRect(QStyleOptionTabWidgetFrameH handle, PRect retval);
C_EXPORT void QStyleOptionTabWidgetFrame_setTabBarRect(QStyleOptionTabWidgetFrameH handle, PRect tabBarRect);
C_EXPORT void QStyleOptionTabWidgetFrame_selectedTabRect(QStyleOptionTabWidgetFrameH handle, PRect retval);
C_EXPORT void QStyleOptionTabWidgetFrame_setSelectedTabRect(QStyleOptionTabWidgetFrameH handle, PRect selectedTabRect);
C_EXPORT QStyleOptionTabWidgetFrameH QStyleOptionTabWidgetFrame_Create();
C_EXPORT void QStyleOptionTabWidgetFrame_Destroy(QStyleOptionTabWidgetFrameH handle);
C_EXPORT QStyleOptionTabWidgetFrameH QStyleOptionTabWidgetFrame_Create2(const QStyleOptionTabWidgetFrameH other);
C_EXPORT QTabBar::Shape QStyleOptionTabBarBase_shape(QStyleOptionTabBarBaseH handle);
C_EXPORT void QStyleOptionTabBarBase_setShape(QStyleOptionTabBarBaseH handle, QTabBar::Shape shape);
C_EXPORT void QStyleOptionTabBarBase_tabBarRect(QStyleOptionTabBarBaseH handle, PRect retval);
C_EXPORT void QStyleOptionTabBarBase_setTabBarRect(QStyleOptionTabBarBaseH handle, PRect tabBarRect);
C_EXPORT void QStyleOptionTabBarBase_selectedTabRect(QStyleOptionTabBarBaseH handle, PRect retval);
C_EXPORT void QStyleOptionTabBarBase_setSelectedTabRect(QStyleOptionTabBarBaseH handle, PRect selectedTabRect);
C_EXPORT bool QStyleOptionTabBarBase_documentMode(QStyleOptionTabBarBaseH handle);
C_EXPORT void QStyleOptionTabBarBase_setDocumentMode(QStyleOptionTabBarBaseH handle, bool documentMode);
C_EXPORT QStyleOptionTabBarBaseH QStyleOptionTabBarBase_Create();
C_EXPORT void QStyleOptionTabBarBase_Destroy(QStyleOptionTabBarBaseH handle);
C_EXPORT QStyleOptionTabBarBaseH QStyleOptionTabBarBase_Create2(const QStyleOptionTabBarBaseH other);
C_EXPORT int QStyleOptionHeader_section(QStyleOptionHeaderH handle);
C_EXPORT void QStyleOptionHeader_setSection(QStyleOptionHeaderH handle, int section);
C_EXPORT void QStyleOptionHeader_text(QStyleOptionHeaderH handle, PWideString retval);
C_EXPORT void QStyleOptionHeader_setText(QStyleOptionHeaderH handle, PWideString text);
C_EXPORT unsigned int QStyleOptionHeader_textAlignment(QStyleOptionHeaderH handle);
C_EXPORT void QStyleOptionHeader_setTextAlignment(QStyleOptionHeaderH handle, unsigned int textAlignment);
C_EXPORT void QStyleOptionHeader_icon(QStyleOptionHeaderH handle, QIconH retval);
C_EXPORT void QStyleOptionHeader_setIcon(QStyleOptionHeaderH handle, QIconH icon);
C_EXPORT unsigned int QStyleOptionHeader_iconAlignment(QStyleOptionHeaderH handle);
C_EXPORT void QStyleOptionHeader_setIconAlignment(QStyleOptionHeaderH handle, unsigned int iconAlignment);
C_EXPORT QStyleOptionHeader::SectionPosition QStyleOptionHeader_position(QStyleOptionHeaderH handle);
C_EXPORT void QStyleOptionHeader_setPosition(QStyleOptionHeaderH handle, QStyleOptionHeader::SectionPosition position);
C_EXPORT QStyleOptionHeader::SelectedPosition QStyleOptionHeader_selectedPosition(QStyleOptionHeaderH handle);
C_EXPORT void QStyleOptionHeader_setSelectedPosition(QStyleOptionHeaderH handle, QStyleOptionHeader::SelectedPosition selectedPosition);
C_EXPORT QStyleOptionHeader::SortIndicator QStyleOptionHeader_sortIndicator(QStyleOptionHeaderH handle);
C_EXPORT void QStyleOptionHeader_setSortIndicator(QStyleOptionHeaderH handle, QStyleOptionHeader::SortIndicator sortIndicator);
C_EXPORT Qt::Orientation QStyleOptionHeader_orientation(QStyleOptionHeaderH handle);
C_EXPORT void QStyleOptionHeader_setOrientation(QStyleOptionHeaderH handle, Qt::Orientation orientation);
C_EXPORT QStyleOptionHeaderH QStyleOptionHeader_Create();
C_EXPORT void QStyleOptionHeader_Destroy(QStyleOptionHeaderH handle);
C_EXPORT QStyleOptionHeaderH QStyleOptionHeader_Create2(const QStyleOptionHeaderH other);
C_EXPORT unsigned int QStyleOptionButton_features(QStyleOptionButtonH handle);
C_EXPORT void QStyleOptionButton_setFeatures(QStyleOptionButtonH handle, unsigned int features);
C_EXPORT void QStyleOptionButton_text(QStyleOptionButtonH handle, PWideString retval);
C_EXPORT void QStyleOptionButton_setText(QStyleOptionButtonH handle, PWideString text);
C_EXPORT void QStyleOptionButton_icon(QStyleOptionButtonH handle, QIconH retval);
C_EXPORT void QStyleOptionButton_setIcon(QStyleOptionButtonH handle, QIconH icon);
C_EXPORT void QStyleOptionButton_iconSize(QStyleOptionButtonH handle, PSize retval);
C_EXPORT void QStyleOptionButton_setIconSize(QStyleOptionButtonH handle, PSize iconSize);
C_EXPORT QStyleOptionButtonH QStyleOptionButton_Create();
C_EXPORT void QStyleOptionButton_Destroy(QStyleOptionButtonH handle);
C_EXPORT QStyleOptionButtonH QStyleOptionButton_Create2(const QStyleOptionButtonH other);
C_EXPORT QTabBar::Shape QStyleOptionTab_shape(QStyleOptionTabH handle);
C_EXPORT void QStyleOptionTab_setShape(QStyleOptionTabH handle, QTabBar::Shape shape);
C_EXPORT void QStyleOptionTab_text(QStyleOptionTabH handle, PWideString retval);
C_EXPORT void QStyleOptionTab_setText(QStyleOptionTabH handle, PWideString text);
C_EXPORT void QStyleOptionTab_icon(QStyleOptionTabH handle, QIconH retval);
C_EXPORT void QStyleOptionTab_setIcon(QStyleOptionTabH handle, QIconH icon);
C_EXPORT int QStyleOptionTab_row(QStyleOptionTabH handle);
C_EXPORT void QStyleOptionTab_setRow(QStyleOptionTabH handle, int row);
C_EXPORT QStyleOptionTab::TabPosition QStyleOptionTab_position(QStyleOptionTabH handle);
C_EXPORT void QStyleOptionTab_setPosition(QStyleOptionTabH handle, QStyleOptionTab::TabPosition position);
C_EXPORT QStyleOptionTab::SelectedPosition QStyleOptionTab_selectedPosition(QStyleOptionTabH handle);
C_EXPORT void QStyleOptionTab_setSelectedPosition(QStyleOptionTabH handle, QStyleOptionTab::SelectedPosition selectedPosition);
C_EXPORT unsigned int QStyleOptionTab_cornerWidgets(QStyleOptionTabH handle);
C_EXPORT void QStyleOptionTab_setCornerWidgets(QStyleOptionTabH handle, unsigned int cornerWidgets);
C_EXPORT void QStyleOptionTab_iconSize(QStyleOptionTabH handle, PSize retval);
C_EXPORT void QStyleOptionTab_setIconSize(QStyleOptionTabH handle, PSize iconSize);
C_EXPORT bool QStyleOptionTab_documentMode(QStyleOptionTabH handle);
C_EXPORT void QStyleOptionTab_setDocumentMode(QStyleOptionTabH handle, bool documentMode);
C_EXPORT void QStyleOptionTab_leftButtonSize(QStyleOptionTabH handle, PSize retval);
C_EXPORT void QStyleOptionTab_setLeftButtonSize(QStyleOptionTabH handle, PSize leftButtonSize);
C_EXPORT void QStyleOptionTab_rightButtonSize(QStyleOptionTabH handle, PSize retval);
C_EXPORT void QStyleOptionTab_setRightButtonSize(QStyleOptionTabH handle, PSize rightButtonSize);
C_EXPORT unsigned int QStyleOptionTab_features(QStyleOptionTabH handle);
C_EXPORT void QStyleOptionTab_setFeatures(QStyleOptionTabH handle, unsigned int features);
C_EXPORT QStyleOptionTabH QStyleOptionTab_Create();
C_EXPORT void QStyleOptionTab_Destroy(QStyleOptionTabH handle);
C_EXPORT QStyleOptionTabH QStyleOptionTab_Create2(const QStyleOptionTabH other);
C_EXPORT QStyleOptionToolBar::ToolBarPosition QStyleOptionToolBar_positionOfLine(QStyleOptionToolBarH handle);
C_EXPORT void QStyleOptionToolBar_setPositionOfLine(QStyleOptionToolBarH handle, QStyleOptionToolBar::ToolBarPosition positionOfLine);
C_EXPORT QStyleOptionToolBar::ToolBarPosition QStyleOptionToolBar_positionWithinLine(QStyleOptionToolBarH handle);
C_EXPORT void QStyleOptionToolBar_setPositionWithinLine(QStyleOptionToolBarH handle, QStyleOptionToolBar::ToolBarPosition positionWithinLine);
C_EXPORT Qt::ToolBarArea QStyleOptionToolBar_toolBarArea(QStyleOptionToolBarH handle);
C_EXPORT void QStyleOptionToolBar_setToolBarArea(QStyleOptionToolBarH handle, Qt::ToolBarArea toolBarArea);
C_EXPORT unsigned int QStyleOptionToolBar_features(QStyleOptionToolBarH handle);
C_EXPORT void QStyleOptionToolBar_setFeatures(QStyleOptionToolBarH handle, unsigned int features);
C_EXPORT int QStyleOptionToolBar_lineWidth(QStyleOptionToolBarH handle);
C_EXPORT void QStyleOptionToolBar_setLineWidth(QStyleOptionToolBarH handle, int lineWidth);
C_EXPORT int QStyleOptionToolBar_midLineWidth(QStyleOptionToolBarH handle);
C_EXPORT void QStyleOptionToolBar_setMidLineWidth(QStyleOptionToolBarH handle, int midLineWidth);
C_EXPORT QStyleOptionToolBarH QStyleOptionToolBar_Create();
C_EXPORT void QStyleOptionToolBar_Destroy(QStyleOptionToolBarH handle);
C_EXPORT QStyleOptionToolBarH QStyleOptionToolBar_Create2(const QStyleOptionToolBarH other);
C_EXPORT int QStyleOptionProgressBar_minimum(QStyleOptionProgressBarH handle);
C_EXPORT void QStyleOptionProgressBar_setMinimum(QStyleOptionProgressBarH handle, int minimum);
C_EXPORT int QStyleOptionProgressBar_maximum(QStyleOptionProgressBarH handle);
C_EXPORT void QStyleOptionProgressBar_setMaximum(QStyleOptionProgressBarH handle, int maximum);
C_EXPORT int QStyleOptionProgressBar_progress(QStyleOptionProgressBarH handle);
C_EXPORT void QStyleOptionProgressBar_setProgress(QStyleOptionProgressBarH handle, int progress);
C_EXPORT void QStyleOptionProgressBar_text(QStyleOptionProgressBarH handle, PWideString retval);
C_EXPORT void QStyleOptionProgressBar_setText(QStyleOptionProgressBarH handle, PWideString text);
C_EXPORT unsigned int QStyleOptionProgressBar_textAlignment(QStyleOptionProgressBarH handle);
C_EXPORT void QStyleOptionProgressBar_setTextAlignment(QStyleOptionProgressBarH handle, unsigned int textAlignment);
C_EXPORT bool QStyleOptionProgressBar_textVisible(QStyleOptionProgressBarH handle);
C_EXPORT void QStyleOptionProgressBar_setTextVisible(QStyleOptionProgressBarH handle, bool textVisible);
C_EXPORT bool QStyleOptionProgressBar_invertedAppearance(QStyleOptionProgressBarH handle);
C_EXPORT void QStyleOptionProgressBar_setInvertedAppearance(QStyleOptionProgressBarH handle, bool invertedAppearance);
C_EXPORT bool QStyleOptionProgressBar_bottomToTop(QStyleOptionProgressBarH handle);
C_EXPORT void QStyleOptionProgressBar_setBottomToTop(QStyleOptionProgressBarH handle, bool bottomToTop);
C_EXPORT QStyleOptionProgressBarH QStyleOptionProgressBar_Create();
C_EXPORT void QStyleOptionProgressBar_Destroy(QStyleOptionProgressBarH handle);
C_EXPORT QStyleOptionProgressBarH QStyleOptionProgressBar_Create2(const QStyleOptionProgressBarH other);
C_EXPORT QStyleOptionMenuItem::MenuItemType QStyleOptionMenuItem_menuItemType(QStyleOptionMenuItemH handle);
C_EXPORT void QStyleOptionMenuItem_setMenuItemType(QStyleOptionMenuItemH handle, QStyleOptionMenuItem::MenuItemType menuItemType);
C_EXPORT QStyleOptionMenuItem::CheckType QStyleOptionMenuItem_checkType(QStyleOptionMenuItemH handle);
C_EXPORT void QStyleOptionMenuItem_setCheckType(QStyleOptionMenuItemH handle, QStyleOptionMenuItem::CheckType checkType);
C_EXPORT bool QStyleOptionMenuItem_checked(QStyleOptionMenuItemH handle);
C_EXPORT void QStyleOptionMenuItem_setChecked(QStyleOptionMenuItemH handle, bool checked);
C_EXPORT bool QStyleOptionMenuItem_menuHasCheckableItems(QStyleOptionMenuItemH handle);
C_EXPORT void QStyleOptionMenuItem_setMenuHasCheckableItems(QStyleOptionMenuItemH handle, bool menuHasCheckableItems);
C_EXPORT void QStyleOptionMenuItem_menuRect(QStyleOptionMenuItemH handle, PRect retval);
C_EXPORT void QStyleOptionMenuItem_setMenuRect(QStyleOptionMenuItemH handle, PRect menuRect);
C_EXPORT void QStyleOptionMenuItem_text(QStyleOptionMenuItemH handle, PWideString retval);
C_EXPORT void QStyleOptionMenuItem_setText(QStyleOptionMenuItemH handle, PWideString text);
C_EXPORT void QStyleOptionMenuItem_icon(QStyleOptionMenuItemH handle, QIconH retval);
C_EXPORT void QStyleOptionMenuItem_setIcon(QStyleOptionMenuItemH handle, QIconH icon);
C_EXPORT int QStyleOptionMenuItem_maxIconWidth(QStyleOptionMenuItemH handle);
C_EXPORT void QStyleOptionMenuItem_setMaxIconWidth(QStyleOptionMenuItemH handle, int maxIconWidth);
C_EXPORT void QStyleOptionMenuItem_font(QStyleOptionMenuItemH handle, QFontH retval);
C_EXPORT void QStyleOptionMenuItem_setFont(QStyleOptionMenuItemH handle, QFontH font);
C_EXPORT QStyleOptionMenuItemH QStyleOptionMenuItem_Create();
C_EXPORT void QStyleOptionMenuItem_Destroy(QStyleOptionMenuItemH handle);
C_EXPORT QStyleOptionMenuItemH QStyleOptionMenuItem_Create2(const QStyleOptionMenuItemH other);
C_EXPORT void QStyleOptionDockWidget_title(QStyleOptionDockWidgetH handle, PWideString retval);
C_EXPORT void QStyleOptionDockWidget_setTitle(QStyleOptionDockWidgetH handle, PWideString title);
C_EXPORT bool QStyleOptionDockWidget_closable(QStyleOptionDockWidgetH handle);
C_EXPORT void QStyleOptionDockWidget_setClosable(QStyleOptionDockWidgetH handle, bool closable);
C_EXPORT bool QStyleOptionDockWidget_movable(QStyleOptionDockWidgetH handle);
C_EXPORT void QStyleOptionDockWidget_setMovable(QStyleOptionDockWidgetH handle, bool movable);
C_EXPORT bool QStyleOptionDockWidget_floatable(QStyleOptionDockWidgetH handle);
C_EXPORT void QStyleOptionDockWidget_setFloatable(QStyleOptionDockWidgetH handle, bool floatable);
C_EXPORT bool QStyleOptionDockWidget_verticalTitleBar(QStyleOptionDockWidgetH handle);
C_EXPORT void QStyleOptionDockWidget_setVerticalTitleBar(QStyleOptionDockWidgetH handle, bool verticalTitleBar);
C_EXPORT QStyleOptionDockWidgetH QStyleOptionDockWidget_Create();
C_EXPORT void QStyleOptionDockWidget_Destroy(QStyleOptionDockWidgetH handle);
C_EXPORT QStyleOptionDockWidgetH QStyleOptionDockWidget_Create2(const QStyleOptionDockWidgetH other);
C_EXPORT unsigned int QStyleOptionViewItem_displayAlignment(QStyleOptionViewItemH handle);
C_EXPORT void QStyleOptionViewItem_setDisplayAlignment(QStyleOptionViewItemH handle, unsigned int displayAlignment);
C_EXPORT unsigned int QStyleOptionViewItem_decorationAlignment(QStyleOptionViewItemH handle);
C_EXPORT void QStyleOptionViewItem_setDecorationAlignment(QStyleOptionViewItemH handle, unsigned int decorationAlignment);
C_EXPORT Qt::TextElideMode QStyleOptionViewItem_textElideMode(QStyleOptionViewItemH handle);
C_EXPORT void QStyleOptionViewItem_setTextElideMode(QStyleOptionViewItemH handle, Qt::TextElideMode textElideMode);
C_EXPORT QStyleOptionViewItem::Position QStyleOptionViewItem_decorationPosition(QStyleOptionViewItemH handle);
C_EXPORT void QStyleOptionViewItem_setDecorationPosition(QStyleOptionViewItemH handle, QStyleOptionViewItem::Position decorationPosition);
C_EXPORT void QStyleOptionViewItem_decorationSize(QStyleOptionViewItemH handle, PSize retval);
C_EXPORT void QStyleOptionViewItem_setDecorationSize(QStyleOptionViewItemH handle, PSize decorationSize);
C_EXPORT void QStyleOptionViewItem_font(QStyleOptionViewItemH handle, QFontH retval);
C_EXPORT void QStyleOptionViewItem_setFont(QStyleOptionViewItemH handle, QFontH font);
C_EXPORT bool QStyleOptionViewItem_showDecorationSelected(QStyleOptionViewItemH handle);
C_EXPORT void QStyleOptionViewItem_setShowDecorationSelected(QStyleOptionViewItemH handle, bool showDecorationSelected);
C_EXPORT unsigned int QStyleOptionViewItem_features(QStyleOptionViewItemH handle);
C_EXPORT void QStyleOptionViewItem_setFeatures(QStyleOptionViewItemH handle, unsigned int features);
C_EXPORT void QStyleOptionViewItem_locale(QStyleOptionViewItemH handle, QLocaleH retval);
C_EXPORT void QStyleOptionViewItem_setLocale(QStyleOptionViewItemH handle, QLocaleH locale);
C_EXPORT const QWidgetH QStyleOptionViewItem_widget(QStyleOptionViewItemH handle);
C_EXPORT void QStyleOptionViewItem_setWidget(QStyleOptionViewItemH handle, const QWidgetH widget);
C_EXPORT void QStyleOptionViewItem_index(QStyleOptionViewItemH handle, QModelIndexH retval);
C_EXPORT void QStyleOptionViewItem_setIndex(QStyleOptionViewItemH handle, QModelIndexH index);
C_EXPORT Qt::CheckState QStyleOptionViewItem_checkState(QStyleOptionViewItemH handle);
C_EXPORT void QStyleOptionViewItem_setCheckState(QStyleOptionViewItemH handle, Qt::CheckState checkState);
C_EXPORT void QStyleOptionViewItem_icon(QStyleOptionViewItemH handle, QIconH retval);
C_EXPORT void QStyleOptionViewItem_setIcon(QStyleOptionViewItemH handle, QIconH icon);
C_EXPORT void QStyleOptionViewItem_text(QStyleOptionViewItemH handle, PWideString retval);
C_EXPORT void QStyleOptionViewItem_setText(QStyleOptionViewItemH handle, PWideString text);
C_EXPORT QStyleOptionViewItem::ViewItemPosition QStyleOptionViewItem_viewItemPosition(QStyleOptionViewItemH handle);
C_EXPORT void QStyleOptionViewItem_setViewItemPosition(QStyleOptionViewItemH handle, QStyleOptionViewItem::ViewItemPosition viewItemPosition);
C_EXPORT void QStyleOptionViewItem_backgroundBrush(QStyleOptionViewItemH handle, QBrushH retval);
C_EXPORT void QStyleOptionViewItem_setBackgroundBrush(QStyleOptionViewItemH handle, QBrushH backgroundBrush);
C_EXPORT QStyleOptionViewItemH QStyleOptionViewItem_Create();
C_EXPORT void QStyleOptionViewItem_Destroy(QStyleOptionViewItemH handle);
C_EXPORT QStyleOptionViewItemH QStyleOptionViewItem_Create2(const QStyleOptionViewItemH other);
C_EXPORT void QStyleOptionToolBox_text(QStyleOptionToolBoxH handle, PWideString retval);
C_EXPORT void QStyleOptionToolBox_setText(QStyleOptionToolBoxH handle, PWideString text);
C_EXPORT void QStyleOptionToolBox_icon(QStyleOptionToolBoxH handle, QIconH retval);
C_EXPORT void QStyleOptionToolBox_setIcon(QStyleOptionToolBoxH handle, QIconH icon);
C_EXPORT QStyleOptionToolBox::TabPosition QStyleOptionToolBox_position(QStyleOptionToolBoxH handle);
C_EXPORT void QStyleOptionToolBox_setPosition(QStyleOptionToolBoxH handle, QStyleOptionToolBox::TabPosition position);
C_EXPORT QStyleOptionToolBox::SelectedPosition QStyleOptionToolBox_selectedPosition(QStyleOptionToolBoxH handle);
C_EXPORT void QStyleOptionToolBox_setSelectedPosition(QStyleOptionToolBoxH handle, QStyleOptionToolBox::SelectedPosition selectedPosition);
C_EXPORT QStyleOptionToolBoxH QStyleOptionToolBox_Create();
C_EXPORT void QStyleOptionToolBox_Destroy(QStyleOptionToolBoxH handle);
C_EXPORT QStyleOptionToolBoxH QStyleOptionToolBox_Create2(const QStyleOptionToolBoxH other);
C_EXPORT QRubberBand::Shape QStyleOptionRubberBand_shape(QStyleOptionRubberBandH handle);
C_EXPORT void QStyleOptionRubberBand_setShape(QStyleOptionRubberBandH handle, QRubberBand::Shape shape);
C_EXPORT bool QStyleOptionRubberBand_opaque(QStyleOptionRubberBandH handle);
C_EXPORT void QStyleOptionRubberBand_setOpaque(QStyleOptionRubberBandH handle, bool opaque);
C_EXPORT QStyleOptionRubberBandH QStyleOptionRubberBand_Create();
C_EXPORT void QStyleOptionRubberBand_Destroy(QStyleOptionRubberBandH handle);
C_EXPORT QStyleOptionRubberBandH QStyleOptionRubberBand_Create2(const QStyleOptionRubberBandH other);
C_EXPORT unsigned int QStyleOptionComplex_subControls(QStyleOptionComplexH handle);
C_EXPORT void QStyleOptionComplex_setSubControls(QStyleOptionComplexH handle, unsigned int subControls);
C_EXPORT unsigned int QStyleOptionComplex_activeSubControls(QStyleOptionComplexH handle);
C_EXPORT void QStyleOptionComplex_setActiveSubControls(QStyleOptionComplexH handle, unsigned int activeSubControls);
C_EXPORT QStyleOptionComplexH QStyleOptionComplex_Create(int version, int type);
C_EXPORT void QStyleOptionComplex_Destroy(QStyleOptionComplexH handle);
C_EXPORT QStyleOptionComplexH QStyleOptionComplex_Create2(const QStyleOptionComplexH other);
C_EXPORT Qt::Orientation QStyleOptionSlider_orientation(QStyleOptionSliderH handle);
C_EXPORT void QStyleOptionSlider_setOrientation(QStyleOptionSliderH handle, Qt::Orientation orientation);
C_EXPORT int QStyleOptionSlider_minimum(QStyleOptionSliderH handle);
C_EXPORT void QStyleOptionSlider_setMinimum(QStyleOptionSliderH handle, int minimum);
C_EXPORT int QStyleOptionSlider_maximum(QStyleOptionSliderH handle);
C_EXPORT void QStyleOptionSlider_setMaximum(QStyleOptionSliderH handle, int maximum);
C_EXPORT QSlider::TickPosition QStyleOptionSlider_tickPosition(QStyleOptionSliderH handle);
C_EXPORT void QStyleOptionSlider_setTickPosition(QStyleOptionSliderH handle, QSlider::TickPosition tickPosition);
C_EXPORT int QStyleOptionSlider_tickInterval(QStyleOptionSliderH handle);
C_EXPORT void QStyleOptionSlider_setTickInterval(QStyleOptionSliderH handle, int tickInterval);
C_EXPORT bool QStyleOptionSlider_upsideDown(QStyleOptionSliderH handle);
C_EXPORT void QStyleOptionSlider_setUpsideDown(QStyleOptionSliderH handle, bool upsideDown);
C_EXPORT int QStyleOptionSlider_sliderPosition(QStyleOptionSliderH handle);
C_EXPORT void QStyleOptionSlider_setSliderPosition(QStyleOptionSliderH handle, int sliderPosition);
C_EXPORT int QStyleOptionSlider_sliderValue(QStyleOptionSliderH handle);
C_EXPORT void QStyleOptionSlider_setSliderValue(QStyleOptionSliderH handle, int sliderValue);
C_EXPORT int QStyleOptionSlider_singleStep(QStyleOptionSliderH handle);
C_EXPORT void QStyleOptionSlider_setSingleStep(QStyleOptionSliderH handle, int singleStep);
C_EXPORT int QStyleOptionSlider_pageStep(QStyleOptionSliderH handle);
C_EXPORT void QStyleOptionSlider_setPageStep(QStyleOptionSliderH handle, int pageStep);
C_EXPORT qreal QStyleOptionSlider_notchTarget(QStyleOptionSliderH handle);
C_EXPORT void QStyleOptionSlider_setNotchTarget(QStyleOptionSliderH handle, qreal notchTarget);
C_EXPORT bool QStyleOptionSlider_dialWrapping(QStyleOptionSliderH handle);
C_EXPORT void QStyleOptionSlider_setDialWrapping(QStyleOptionSliderH handle, bool dialWrapping);
C_EXPORT QStyleOptionSliderH QStyleOptionSlider_Create();
C_EXPORT void QStyleOptionSlider_Destroy(QStyleOptionSliderH handle);
C_EXPORT QStyleOptionSliderH QStyleOptionSlider_Create2(const QStyleOptionSliderH other);
C_EXPORT QAbstractSpinBox::ButtonSymbols QStyleOptionSpinBox_buttonSymbols(QStyleOptionSpinBoxH handle);
C_EXPORT void QStyleOptionSpinBox_setButtonSymbols(QStyleOptionSpinBoxH handle, QAbstractSpinBox::ButtonSymbols buttonSymbols);
C_EXPORT unsigned int QStyleOptionSpinBox_stepEnabled(QStyleOptionSpinBoxH handle);
C_EXPORT void QStyleOptionSpinBox_setStepEnabled(QStyleOptionSpinBoxH handle, unsigned int stepEnabled);
C_EXPORT bool QStyleOptionSpinBox_frame(QStyleOptionSpinBoxH handle);
C_EXPORT void QStyleOptionSpinBox_setFrame(QStyleOptionSpinBoxH handle, bool frame);
C_EXPORT QStyleOptionSpinBoxH QStyleOptionSpinBox_Create();
C_EXPORT void QStyleOptionSpinBox_Destroy(QStyleOptionSpinBoxH handle);
C_EXPORT QStyleOptionSpinBoxH QStyleOptionSpinBox_Create2(const QStyleOptionSpinBoxH other);
C_EXPORT unsigned int QStyleOptionToolButton_features(QStyleOptionToolButtonH handle);
C_EXPORT void QStyleOptionToolButton_setFeatures(QStyleOptionToolButtonH handle, unsigned int features);
C_EXPORT void QStyleOptionToolButton_icon(QStyleOptionToolButtonH handle, QIconH retval);
C_EXPORT void QStyleOptionToolButton_setIcon(QStyleOptionToolButtonH handle, QIconH icon);
C_EXPORT void QStyleOptionToolButton_iconSize(QStyleOptionToolButtonH handle, PSize retval);
C_EXPORT void QStyleOptionToolButton_setIconSize(QStyleOptionToolButtonH handle, PSize iconSize);
C_EXPORT void QStyleOptionToolButton_text(QStyleOptionToolButtonH handle, PWideString retval);
C_EXPORT void QStyleOptionToolButton_setText(QStyleOptionToolButtonH handle, PWideString text);
C_EXPORT Qt::ArrowType QStyleOptionToolButton_arrowType(QStyleOptionToolButtonH handle);
C_EXPORT void QStyleOptionToolButton_setArrowType(QStyleOptionToolButtonH handle, Qt::ArrowType arrowType);
C_EXPORT Qt::ToolButtonStyle QStyleOptionToolButton_toolButtonStyle(QStyleOptionToolButtonH handle);
C_EXPORT void QStyleOptionToolButton_setToolButtonStyle(QStyleOptionToolButtonH handle, Qt::ToolButtonStyle toolButtonStyle);
C_EXPORT void QStyleOptionToolButton_pos(QStyleOptionToolButtonH handle, PQtPoint retval);
C_EXPORT void QStyleOptionToolButton_setPos(QStyleOptionToolButtonH handle, PQtPoint pos);
C_EXPORT void QStyleOptionToolButton_font(QStyleOptionToolButtonH handle, QFontH retval);
C_EXPORT void QStyleOptionToolButton_setFont(QStyleOptionToolButtonH handle, QFontH font);
C_EXPORT QStyleOptionToolButtonH QStyleOptionToolButton_Create();
C_EXPORT void QStyleOptionToolButton_Destroy(QStyleOptionToolButtonH handle);
C_EXPORT QStyleOptionToolButtonH QStyleOptionToolButton_Create2(const QStyleOptionToolButtonH other);
C_EXPORT bool QStyleOptionComboBox_editable(QStyleOptionComboBoxH handle);
C_EXPORT void QStyleOptionComboBox_setEditable(QStyleOptionComboBoxH handle, bool editable);
C_EXPORT void QStyleOptionComboBox_popupRect(QStyleOptionComboBoxH handle, PRect retval);
C_EXPORT void QStyleOptionComboBox_setPopupRect(QStyleOptionComboBoxH handle, PRect popupRect);
C_EXPORT bool QStyleOptionComboBox_frame(QStyleOptionComboBoxH handle);
C_EXPORT void QStyleOptionComboBox_setFrame(QStyleOptionComboBoxH handle, bool frame);
C_EXPORT void QStyleOptionComboBox_currentText(QStyleOptionComboBoxH handle, PWideString retval);
C_EXPORT void QStyleOptionComboBox_setCurrentText(QStyleOptionComboBoxH handle, PWideString currentText);
C_EXPORT void QStyleOptionComboBox_currentIcon(QStyleOptionComboBoxH handle, QIconH retval);
C_EXPORT void QStyleOptionComboBox_setCurrentIcon(QStyleOptionComboBoxH handle, QIconH currentIcon);
C_EXPORT void QStyleOptionComboBox_iconSize(QStyleOptionComboBoxH handle, PSize retval);
C_EXPORT void QStyleOptionComboBox_setIconSize(QStyleOptionComboBoxH handle, PSize iconSize);
C_EXPORT QStyleOptionComboBoxH QStyleOptionComboBox_Create();
C_EXPORT void QStyleOptionComboBox_Destroy(QStyleOptionComboBoxH handle);
C_EXPORT QStyleOptionComboBoxH QStyleOptionComboBox_Create2(const QStyleOptionComboBoxH other);
C_EXPORT void QStyleOptionTitleBar_text(QStyleOptionTitleBarH handle, PWideString retval);
C_EXPORT void QStyleOptionTitleBar_setText(QStyleOptionTitleBarH handle, PWideString text);
C_EXPORT void QStyleOptionTitleBar_icon(QStyleOptionTitleBarH handle, QIconH retval);
C_EXPORT void QStyleOptionTitleBar_setIcon(QStyleOptionTitleBarH handle, QIconH icon);
C_EXPORT int QStyleOptionTitleBar_titleBarState(QStyleOptionTitleBarH handle);
C_EXPORT void QStyleOptionTitleBar_setTitleBarState(QStyleOptionTitleBarH handle, int titleBarState);
C_EXPORT unsigned int QStyleOptionTitleBar_titleBarFlags(QStyleOptionTitleBarH handle);
C_EXPORT void QStyleOptionTitleBar_setTitleBarFlags(QStyleOptionTitleBarH handle, unsigned int titleBarFlags);
C_EXPORT QStyleOptionTitleBarH QStyleOptionTitleBar_Create();
C_EXPORT void QStyleOptionTitleBar_Destroy(QStyleOptionTitleBarH handle);
C_EXPORT QStyleOptionTitleBarH QStyleOptionTitleBar_Create2(const QStyleOptionTitleBarH other);
C_EXPORT unsigned int QStyleOptionGroupBox_features(QStyleOptionGroupBoxH handle);
C_EXPORT void QStyleOptionGroupBox_setFeatures(QStyleOptionGroupBoxH handle, unsigned int features);
C_EXPORT void QStyleOptionGroupBox_text(QStyleOptionGroupBoxH handle, PWideString retval);
C_EXPORT void QStyleOptionGroupBox_setText(QStyleOptionGroupBoxH handle, PWideString text);
C_EXPORT unsigned int QStyleOptionGroupBox_textAlignment(QStyleOptionGroupBoxH handle);
C_EXPORT void QStyleOptionGroupBox_setTextAlignment(QStyleOptionGroupBoxH handle, unsigned int textAlignment);
C_EXPORT void QStyleOptionGroupBox_textColor(QStyleOptionGroupBoxH handle, PQColor retval);
C_EXPORT void QStyleOptionGroupBox_setTextColor(QStyleOptionGroupBoxH handle, PQColor textColor);
C_EXPORT int QStyleOptionGroupBox_lineWidth(QStyleOptionGroupBoxH handle);
C_EXPORT void QStyleOptionGroupBox_setLineWidth(QStyleOptionGroupBoxH handle, int lineWidth);
C_EXPORT int QStyleOptionGroupBox_midLineWidth(QStyleOptionGroupBoxH handle);
C_EXPORT void QStyleOptionGroupBox_setMidLineWidth(QStyleOptionGroupBoxH handle, int midLineWidth);
C_EXPORT QStyleOptionGroupBoxH QStyleOptionGroupBox_Create();
C_EXPORT void QStyleOptionGroupBox_Destroy(QStyleOptionGroupBoxH handle);
C_EXPORT QStyleOptionGroupBoxH QStyleOptionGroupBox_Create2(const QStyleOptionGroupBoxH other);
C_EXPORT Qt::Corner QStyleOptionSizeGrip_corner(QStyleOptionSizeGripH handle);
C_EXPORT void QStyleOptionSizeGrip_setCorner(QStyleOptionSizeGripH handle, Qt::Corner corner);
C_EXPORT QStyleOptionSizeGripH QStyleOptionSizeGrip_Create();
C_EXPORT void QStyleOptionSizeGrip_Destroy(QStyleOptionSizeGripH handle);
C_EXPORT QStyleOptionSizeGripH QStyleOptionSizeGrip_Create2(const QStyleOptionSizeGripH other);
C_EXPORT void QStyleOptionGraphicsItem_exposedRect(QStyleOptionGraphicsItemH handle, QRectFH retval);
C_EXPORT void QStyleOptionGraphicsItem_setExposedRect(QStyleOptionGraphicsItemH handle, QRectFH exposedRect);
C_EXPORT QStyleOptionGraphicsItemH QStyleOptionGraphicsItem_Create();
C_EXPORT void QStyleOptionGraphicsItem_Destroy(QStyleOptionGraphicsItemH handle);
C_EXPORT QStyleOptionGraphicsItemH QStyleOptionGraphicsItem_Create2(const QStyleOptionGraphicsItemH other);
C_EXPORT qreal QStyleOptionGraphicsItem_levelOfDetailFromTransform(const QTransformH worldTransform);
C_EXPORT int QStyleHintReturn_version(QStyleHintReturnH handle);
C_EXPORT void QStyleHintReturn_setVersion(QStyleHintReturnH handle, int version);
C_EXPORT int QStyleHintReturn_type(QStyleHintReturnH handle);
C_EXPORT void QStyleHintReturn_setType(QStyleHintReturnH handle, int type);
C_EXPORT QStyleHintReturnH QStyleHintReturn_Create(int version, int type);
C_EXPORT void QStyleHintReturn_Destroy(QStyleHintReturnH handle);
C_EXPORT void QStyleHintReturnMask_region(QStyleHintReturnMaskH handle, QRegionH retval);
C_EXPORT void QStyleHintReturnMask_setRegion(QStyleHintReturnMaskH handle, QRegionH region);
C_EXPORT QStyleHintReturnMaskH QStyleHintReturnMask_Create();
C_EXPORT void QStyleHintReturnMask_Destroy(QStyleHintReturnMaskH handle);
C_EXPORT void QStyleHintReturnVariant_variant(QStyleHintReturnVariantH handle, QVariantH retval);
C_EXPORT void QStyleHintReturnVariant_setVariant(QStyleHintReturnVariantH handle, QVariantH variant);
C_EXPORT QStyleHintReturnVariantH QStyleHintReturnVariant_Create();
C_EXPORT void QStyleHintReturnVariant_Destroy(QStyleHintReturnVariantH handle);

#endif
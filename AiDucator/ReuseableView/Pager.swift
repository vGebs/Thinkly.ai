//
//  Pager.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-18.
//

import Foundation
import SwiftUI

//We are going to create our own view using ViewBuilders
struct Pager<Content: View>: UIViewRepresentable {
    
    //To store our SwiftUIView
    var content: Content
    
    //Getting rect to calculate width and height of scrollview
    var rect: CGRect
    
    //Content offset
    @Binding var offset: CGFloat
    
    //Tabs...
    var tabs: [Any]
    
    //ScrollView
    //For paging
    let scrollView = UIScrollView()
    
    init(tabs: [Any], rect: CGRect, offset: Binding<CGFloat>, @ViewBuilder content: ()-> Content) {
        self.content = content()
        self._offset = offset
        self.rect = rect
        self.tabs = tabs
    }
    
    func makeCoordinator() -> Coordinator {
        return Pager.Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> UIScrollView {
        setupScrollView()
        
        //Setting content size
        scrollView.contentSize = CGSize(width: rect.width * CGFloat(tabs.count), height: rect.height)
        
        scrollView.addSubview(extractView())
        
        scrollView.delegate = context.coordinator
        
        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        if uiView.contentOffset.x != offset {
            
            uiView.delegate = nil
            
            UIView.animate(withDuration: 0.4) {
                uiView.contentOffset.x = offset
            } completion: { status in
                if status { uiView.delegate = context.coordinator }
            }
        }
    }
    
    //Setting up scrollview
    func setupScrollView() {
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
    }
    
    //Extracting SwiftUI View
    func extractView() -> UIView {
        
        //Since it depends on tab size
        //so get the tabs
        let controller = UIHostingController(rootView: content)
        controller.view.frame = CGRect(x: 0, y: 0, width: rect.width * CGFloat(tabs.count), height: rect.height)
        
        return controller.view!
    }
    
    //Delegate function to get offset
    class Coordinator: NSObject, UIScrollViewDelegate {
        
        var parent: Pager
        
        init(parent: Pager) {
            self.parent = parent
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            parent.offset = scrollView.contentOffset.x
        }
    }
}

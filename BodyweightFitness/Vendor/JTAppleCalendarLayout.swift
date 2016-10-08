import UIKit

public class JTAppleCalendarLayout: UICollectionViewLayout, JTAppleCalendarLayoutProtocol {
    let errorDelta: CGFloat = 0.0000001
    var itemSize: CGSize = CGSizeZero
    var headerReferenceSize: CGSize = CGSizeZero
    var scrollDirection: UICollectionViewScrollDirection = .Horizontal
    var maxSections: Int = 0
    var daysPerSection: Int = 0
    
    var numberOfColumns: Int { get { return delegate.numberOfColumns() } }
    var numberOfMonthsInCalendar: Int { get { return delegate.numberOfMonthsInCalendar() } }
    var numberOfSectionsPerMonth: Int { get { return delegate.numberOfsectionsPermonth() } }
    var numberOfDaysPerSection: Int { get { return delegate.numberOfDaysPerSection() } }
    var numberOfRows: Int { get { return delegate.numberOfRows() } }
    
    var cellCache: [Int:[UICollectionViewLayoutAttributes]] = [:]
    var headerCache: [UICollectionViewLayoutAttributes] = []
    var sectionSize: [CGFloat] = []
    
    weak var delegate: JTAppleCalendarDelegateProtocol!
    
    var currentHeader: (section: Int, size: CGSize)? // Tracks the current header size
    var currentCell: (section: Int, itemSize: CGSize)? // Tracks the current cell size
    
    var contentHeight: CGFloat = 0 // Content height of calendarView
    var contentWidth: CGFloat = 0 // Content wifth of calendarView
    
    init(withDelegate delegate: JTAppleCalendarDelegateProtocol) {
        super.init()
        self.delegate = delegate
    }
    
    /// Tells the layout object to update the current layout.
    public override func prepareLayout() {
        if !cellCache.isEmpty { return }
        
        maxSections = numberOfMonthsInCalendar * numberOfSectionsPerMonth
        daysPerSection = numberOfDaysPerSection
        
         // Generate and cache the headers
        for section in 0..<maxSections {
            let sectionIndexPath = NSIndexPath(forItem: 0, inSection: section)
            if let aHeaderAttr = layoutAttributesForSupplementaryViewOfKind(UICollectionElementKindSectionHeader, atIndexPath: sectionIndexPath) {
                headerCache.append(aHeaderAttr)
                if scrollDirection == .Vertical { contentHeight += aHeaderAttr.frame.height } else { contentWidth += aHeaderAttr.frame.width }
            }
            
            // Generate and cache the cells
            for item in 0..<daysPerSection {
                let indexPath = NSIndexPath(forItem: item, inSection: section)
                if let attribute = layoutAttributesForItemAtIndexPath(indexPath) {
                    if cellCache[section] == nil {
                        cellCache[section] = []
                        if scrollDirection == .Vertical { contentHeight += (attribute.frame.height * CGFloat(numberOfRows)) }
                    }
                    cellCache[section]!.append(attribute)
                }
            }
            // Save the content size for each section
            sectionSize.append(scrollDirection == .Horizontal ? contentWidth : contentHeight)

        }
        if delegate.registeredHeaderViews.count < 1 { headerCache.removeAll() } // Get rid of header data if dev didnt register headers. The were used for calculation but are not needed to be displayed
        if scrollDirection == .Horizontal { contentHeight = self.collectionView!.bounds.size.height } else { contentWidth = self.collectionView!.bounds.size.width }
    }
    
    /// Returns the width and height of the collection view’s contents. The width and height of the collection view’s contents.
    public override func collectionViewContentSize() -> CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    /// Returns the layout attributes for all of the cells and views in the specified rectangle.
    override public func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let startSectionIndex = startIndexFrom(rectOrigin: rect.origin)
        
        // keep looping until there were no interception rects
        var attributes: [UICollectionViewLayoutAttributes] = []
        let maxMissCount = scrollDirection == .Horizontal ? MAX_NUMBER_OF_ROWS_PER_MONTH : MAX_NUMBER_OF_DAYS_IN_WEEK
        var beganIntercepting = false
        var missCount = 0
        for sectionIndex in startSectionIndex..<cellCache.count {
            if let validSection = cellCache[sectionIndex] where validSection.count > 0 {
                // Add header view attributes
                if delegate.registeredHeaderViews.count > 0 {
                    if CGRectIntersectsRect(headerCache[sectionIndex].frame, rect) { attributes.append(headerCache[sectionIndex]) }
                }
                
                for val in validSection {
                    if CGRectIntersectsRect(val.frame, rect) {
                        missCount = 0
                        beganIntercepting = true
                        attributes.append(val)
                    } else {
                        missCount += 1
                        if missCount > maxMissCount && beganIntercepting { break }// If there are at least 8 misses in a row since intercepting began, then this section has no more interceptions. So break
                    }
                }
                if missCount > maxMissCount && beganIntercepting { break }// Also break from outter loop
            }
        }
        return attributes
    }
    
    /// Returns the layout attributes for the item at the specified index path. A layout attributes object containing the information to apply to the item’s cell.
    
    override  public func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        
        if !(0...maxSections ~= indexPath.section) || !(0...numberOfDaysPerSection  ~= indexPath.item) { return nil} // return nil on invalid range
        let attr = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        
        // If this index is already cached, then return it else, apply a new layout attribut to it
        if let alreadyCachedCellAttrib = cellCache[indexPath.section] where indexPath.item < alreadyCachedCellAttrib.count {
            return alreadyCachedCellAttrib[indexPath.item]
        }
        applyLayoutAttributes(attr)
        return attr
    }
    
    /// Returns the layout attributes for the specified supplementary view.
    public override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, withIndexPath: indexPath)
        
        // We cache the header here so we dont call the delegate so much
        let headerSize = cachedHeaderSizeForSection(indexPath.section)
        var strideOffset: CGFloat = 0
        if indexPath.section > 0 {
            var headerSizeOfPreviousSection: CGFloat
            var itemSectionSizeOfPreviousSection: CGFloat
            
            if scrollDirection == .Vertical {
                headerSizeOfPreviousSection = headerCache[attributes.indexPath.section - 1].frame.height
                itemSectionSizeOfPreviousSection = cellCache[attributes.indexPath.section - 1]![0].frame.height * CGFloat(numberOfRows)
                strideOffset = itemSectionSizeOfPreviousSection + headerSizeOfPreviousSection + headerCache[attributes.indexPath.section - 1].frame.origin.y
            } else {
                headerSizeOfPreviousSection = headerCache[attributes.indexPath.section - 1].frame.width
                itemSectionSizeOfPreviousSection = cellCache[attributes.indexPath.section - 1]![0].frame.width * CGFloat(numberOfColumns)
                strideOffset = itemSectionSizeOfPreviousSection * CGFloat(indexPath.section)
            }
        }
        
        // Use the calculaed header size and force thw width of the header to take up 7 columns
        let modifiedSize = CGSize(width: itemSize.width * CGFloat(numberOfColumns), height: headerSize.height)
        
        attributes.frame = scrollDirection == .Horizontal ? CGRect(x: strideOffset, y: 0, width: modifiedSize.width, height: modifiedSize.height) : CGRect(x: 0, y: strideOffset, width: modifiedSize.width, height: modifiedSize.height)
        if attributes.frame == CGRectZero { return nil }
        return attributes
    }
    
    func applyLayoutAttributes(attributes : UICollectionViewLayoutAttributes) {
        if attributes.representedElementKind != nil { return }
    
        // Calculate the item size
        if let itemSize = delegate!.itemSize {
            if scrollDirection == .Vertical {
                self.itemSize.height = itemSize
            } else {
                self.itemSize.width = itemSize
                self.itemSize.height = sizeForitemAtIndexPath(attributes.indexPath).height
            }
        } else { itemSize = sizeForitemAtIndexPath(attributes.indexPath) } // jt101 the width is already set form the outside. may change this to all inside here.
        
        
        // Calculate the item stride
        var stride: CGFloat = 0
        
        if delegate.registeredHeaderViews.count > 0 { // If we have headers the cell must start under the header
            let headerSize = headerCache[attributes.indexPath.section].frame.height
            let headerOrigin = headerCache[attributes.indexPath.section].frame.origin.y
            if scrollDirection == .Vertical { // Headers will affect the stride of Vertical NOT Horizontal
                stride += headerSize + headerOrigin
            } else {
                stride += CGFloat(attributes.indexPath.section) * itemSize.width * CGFloat(numberOfColumns)
            }
        } else { // If there are no headers then all the cells will have the same height, therefore the strides will have the same height
            stride = scrollDirection == .Horizontal ? CGFloat(attributes.indexPath.section) * itemSize.width * CGFloat(numberOfColumns): CGFloat(attributes.indexPath.section) * itemSize.height * CGFloat(numberOfRows)
        }
        
        var xCellOffset : CGFloat = CGFloat(attributes.indexPath.item % MAX_NUMBER_OF_DAYS_IN_WEEK) * self.itemSize.width
        var yCellOffset :CGFloat = CGFloat(attributes.indexPath.item / MAX_NUMBER_OF_DAYS_IN_WEEK) * self.itemSize.height
        
        if scrollDirection == .Horizontal {
            xCellOffset += stride
            
            // Headers will affect the start origin of Horizontal layout. Vertical layout is already accounted for in the stride because
            // you are scrolling in the same direction as the headers height. Thus, headers affect vertical stride, while it affects Horizontal offsets
            if delegate.registeredHeaderViews.count > 0 {
                yCellOffset += headerCache[attributes.indexPath.section].frame.height // Adjust the y ofset
            }
        } else {
            yCellOffset += stride
        }
        attributes.frame = CGRectMake(xCellOffset, yCellOffset, self.itemSize.width, self.itemSize.height)
    }
    
    func cachedHeaderSizeForSection(section: Int) -> CGSize {
        // We cache the header here so we dont call the delegate so much
        var headerSize = CGSizeZero
        if let cachedHeader  = currentHeader where cachedHeader.section == section {
            headerSize = cachedHeader.size
        } else {
            headerSize = delegate!.referenceSizeForHeaderInSection(section)
            currentHeader = (section, headerSize)
        }
        return headerSize
    }
    
    func sizeForitemAtIndexPath(indexPath: NSIndexPath) -> CGSize {
        // Return the size if the cell size is already cached
        if let cachedCell  = currentCell where cachedCell.section == indexPath.section { return cachedCell.itemSize }
        
        // Get header size if it alrady cached
        var headerSize =  CGSizeZero
        if delegate.registeredHeaderViews.count > 0 { headerSize = cachedHeaderSizeForSection(indexPath.section) }
        let currentItemSize = itemSize
        let size            = CGSize(width: currentItemSize.width, height: (collectionView!.frame.height - headerSize.height) / CGFloat(numberOfRows))
        currentCell         = (section: indexPath.section, itemSize: size)
        return size
    }
    
    func sizeOfSection(section: Int)-> CGFloat {
        if scrollDirection == .Horizontal {
            return cellCache[section]![0].frame.width * CGFloat(numberOfColumns)
        } else {
            let headerSizeOfSection = headerCache.count > 0 ? headerCache[section].frame.height : 0
            return cellCache[section]![0].frame.height * CGFloat(numberOfRows) + headerSizeOfSection
        }
    }
    
    func startIndexFrom(rectOrigin offset: CGPoint)-> Int {
        let key =  scrollDirection == .Horizontal ? offset.x : offset.y
        return startIndexBinarySearch(sectionSize, offset: key)
    }
    
    func sizeOfContentForSection(section: Int) -> CGFloat {
        return sizeOfSection(section)
    }

    func sectionFromRectOffset(offset: CGPoint)-> Int {
        let theOffet = scrollDirection == .Horizontal ? offset.x : offset.y
        return sectionFromOffset(theOffet)
    }
    func sectionFromOffset(theOffSet: CGFloat) -> Int {
        var val: Int = 0
        for (index, sectionSizeValue) in sectionSize.enumerate() {
            if abs(theOffSet - sectionSizeValue) < errorDelta { continue }
            if theOffSet < sectionSizeValue {
                val = index
                break
            }
        }
        return val
    }
    
    func startIndexBinarySearch<T: Comparable>(a: [T], offset: T) -> Int {
        if a.count < 3 { return 0} // If the range is less than 2 just break here.
        var range = 0..<a.count
        var midIndex: Int = 0
        while range.startIndex < range.endIndex {
            midIndex = range.startIndex + (range.endIndex - range.startIndex) / 2
            if midIndex + 1  >= a.count || offset >= a[midIndex] && offset < a[midIndex + 1] ||  a[midIndex] == offset {
                break
            } else if a[midIndex] < offset {
                range.startIndex = midIndex + 1
            } else {
                range.endIndex = midIndex
            }
        }
        return midIndex
    }
    
    /// Returns an object initialized from data in a given unarchiver. self, initialized using the data in decoder.
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// Returns the content offset to use after an animation layout update or change.
    /// - Parameter proposedContentOffset: The proposed point for the upper-left corner of the visible content
    /// - returns: The content offset that you want to use instead
    public override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint) -> CGPoint {
        return proposedContentOffset
    }
    
    func clearCache() {
        headerCache.removeAll()
        cellCache.removeAll()
        sectionSize.removeAll()
        currentHeader = nil
        currentCell = nil
        contentHeight = 0
        contentWidth = 0
    }
}
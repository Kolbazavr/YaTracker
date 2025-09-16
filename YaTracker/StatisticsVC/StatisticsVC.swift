import UIKit
import SwiftUI

final class StatisticsVC: UIViewController {
    
    private var hostingController: UIHostingController<StatCardView>?
    private let recordStore: TrackerRecordStore
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("statistics", comment: "StatisticsHeader")
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textAlignment = .left
        return label
    }()
    
    private let emptyStateImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(resource: .sadSmile))
        imageView.isHidden = true
        return imageView
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("there_is_nothing_to_analyze_yet", comment: "EmptyStateLabel")
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addViews()
        fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
    }
    
    init(recordStore: TrackerRecordStore) {
        self.recordStore = recordStore
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func fetchData() {
        let completedCount = recordStore.allRecordsCount()
        let (perfectDays, bestPeriod, average) = recordStore.findStatisticsData()
        let data: [ (String, Int) ] = [
            (NSLocalizedString("best_period", comment: "BestPeriod"), bestPeriod),
            (NSLocalizedString("ideal_days", comment: "IdealDays"), perfectDays.count),
            (NSLocalizedString("trackers_completed", comment: "CompletedTrackers"), completedCount),
            (NSLocalizedString("average_value", comment: "Average"), average)
        ]
        hostingController?.rootView = StatCardView(data: data)
        
        emptyStateImage.isHidden = completedCount > 0
        emptyStateLabel.isHidden = completedCount > 0
        hostingController?.view.isHidden = completedCount == 0
    }
    
    private func addViews() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        hostingController = UIHostingController(rootView: StatCardView(data: []))
        guard let hostingController else { return }
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        emptyStateImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyStateImage)
        
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyStateLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleLabel.heightAnchor.constraint(equalToConstant: 138),
            
            emptyStateImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImage.bottomAnchor, constant: 8),
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            hostingController.view.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        hostingController.didMove(toParent: self)
    }
}

import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ChapterInstallationComponent } from './chapter-installation.component';

describe('ChapterInstallationComponent', () => {
  let component: ChapterInstallationComponent;
  let fixture: ComponentFixture<ChapterInstallationComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [ChapterInstallationComponent]
    })
    .compileComponents();
    
    fixture = TestBed.createComponent(ChapterInstallationComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
